 

pragma solidity ^0.4.24;

  
library SafeMath {
    function mul(uint256 a, uint256 b) internal pure returns (uint256) {
        if (a == 0) {
            return 0;
        }
        uint256 c = a * b;
        assert(c / a == b);
        return c;
    }

    function div(uint256 a, uint256 b) internal pure returns (uint256) {
        assert(b > 0); 
        uint256 c = a / b;
        return c;
    }

    function sub(uint256 a, uint256 b) internal pure returns (uint256) {
        assert(b <= a);
        return a - b;
    }

    function add(uint256 a, uint256 b) internal pure returns (uint256) {
        uint256 c = a + b;
        assert(c >= a);
        return c;
    }
}

 
contract ERC20 {
    uint256 public totalSupply;
    function balanceOf(address who) public view returns (uint256);
    function transfer(address to, uint256 value) public returns (bool);
    function allowance(address owner, address spender) public view returns (uint256);
    function transferFrom(address from, address to, uint256 value) public returns (bool);
    function approve(address spender, uint256 value) public returns (bool);

    event Transfer(address indexed from, address indexed to, uint256 value);
    event Approval(address indexed owner, address indexed spender, uint256 value);
}

contract Owned {
    address public owner;

    event OwnershipTransferred(address indexed _from, address indexed _to);

    constructor(address _owner) public {
        owner = _owner;
    }

    modifier onlyOwner {
        require(msg.sender == owner);
        _;
    }

    function transferOwnership(address _owner) onlyOwner public {
        require(_owner != address(0));
        owner = _owner;

        emit OwnershipTransferred(owner, _owner);
    }
}

contract ERC20Token is ERC20, Owned {
    using SafeMath for uint256;

    mapping(address => uint256) balances;
    mapping(address => mapping (address => uint256)) allowed;


     
    bool public transferable = true;

    modifier canTransfer() {
        require(transferable == true);
        _;
    }

    function setTransferable(bool _transferable) onlyOwner public {
        transferable = _transferable;
    }

     
    function transfer(address _to, uint256 _value) canTransfer public returns (bool) {
        require(_to != address(0));
        require(_value <= balances[msg.sender]);

        balances[msg.sender] = balances[msg.sender].sub(_value);
        balances[_to] = balances[_to].add(_value);
        emit Transfer(msg.sender, _to, _value);
        return true;
    }

     
    function balanceOf(address _owner) public view returns (uint256 balance) {
        return balances[_owner];
    }

     
    function transferFrom(address _from, address _to, uint256 _value) canTransfer public returns (bool) {
        require(_to != address(0));
        require(_value <= balances[_from]);
        require(_value <= allowed[_from][msg.sender]);

        balances[_from] = balances[_from].sub(_value);
        balances[_to] = balances[_to].add(_value);
        allowed[_from][msg.sender] = allowed[_from][msg.sender].sub(_value);
        emit Transfer(_from, _to, _value);
        return true;
    }

     
    function approve(address _spender, uint _value) public returns (bool success) {
         
         
         
         
        if ((_value != 0) && (allowed[msg.sender][_spender] != 0)) {
            revert();
        }
        allowed[msg.sender][_spender] = _value;
        emit Approval(msg.sender, _spender, _value);
        return true;
    }

     
    function allowance(address _owner, address _spender) public view returns (uint256) {
        return allowed[_owner][_spender];
    }

    function signature() public view returns (string) {
        return "provided by Seal-SC / www.sealsc.com";
    }

    function () public payable {
        revert();
    }
}

contract Erc20Base is ERC20Token{
    string public name;
    string public symbol;
    uint8 public decimals;

    constructor(address _issuer,string _name,string _symbol,uint256 _totalSupplyCap,uint8 _decimals) public Owned(_issuer){
        name = _name;
        symbol = _symbol;
        decimals = _decimals;
        totalSupply = _totalSupplyCap;
        balances[_issuer] = _totalSupplyCap;
        emit Transfer(address(0), _issuer, _totalSupplyCap);
    }
}