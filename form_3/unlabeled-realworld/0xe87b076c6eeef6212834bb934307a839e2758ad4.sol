 

pragma solidity ^0.4.22;

 
library SafeMath {
  function mul(uint256 a, uint256 b) internal pure returns (uint256) {
    uint256 c = a * b;
    assert(a == 0 || c / a == b);
    return c;
  }

  function div(uint256 a, uint256 b) internal pure returns (uint256) {
     
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

 
contract ERC20Basic {
  uint256 public totalSupply;
  function balanceOf(address who) constant returns (uint256);
  function transfer(address to, uint256 value) returns (bool);
  event Transfer(address indexed from, address indexed to, uint256 value);
}

 
contract ERC20 is ERC20Basic {
  function allowance(address owner, address spender) constant returns (uint256);
  function transferFrom(address from, address to, uint256 value) returns (bool);
  function approve(address spender, uint256 value) returns (bool);
  event Approval(address indexed owner, address indexed spender, uint256 value);
}

 
contract BasicToken is ERC20Basic {
  using SafeMath for uint256;

  mapping(address => uint256) balances;

   
  function transfer(address _to, uint256 _value) returns (bool) {
    balances[msg.sender] = balances[msg.sender].sub(_value);
    balances[_to] = balances[_to].add(_value);
    emit Transfer(msg.sender, _to, _value);
    return true;
  }

   
  function balanceOf(address _owner) constant returns (uint256 balance) {
    return balances[_owner];
  }

}

 
contract StandardToken is ERC20, BasicToken {

  mapping (address => mapping (address => uint256)) allowed;


   
  function transferFrom(address _from, address _to, uint256 _value) returns (bool) {
    var _allowance = allowed[_from][msg.sender];

     
     

    balances[_to] = balances[_to].add(_value);
    balances[_from] = balances[_from].sub(_value);
    allowed[_from][msg.sender] = _allowance.sub(_value);
    emit Transfer(_from, _to, _value);
    return true;
  }

   
  function approve(address _spender, uint256 _value) returns (bool) {

     
     
     
     
    require((_value == 0) || (allowed[msg.sender][_spender] == 0));

    allowed[msg.sender][_spender] = _value;
    emit Approval(msg.sender, _spender, _value);
    return true;
  }

   
  function allowance(address _owner, address _spender) constant returns (uint256 remaining) {
    return allowed[_owner][_spender];
  }

}


 
contract Ownable {
  address public owner;


   
  function Ownable() {
    owner = msg.sender;
  }


   
  modifier onlyOwner() {
    require(msg.sender == owner);
    _;
  }


   
  function transferOwnership(address newOwner) onlyOwner {
    if (newOwner != address(0)) {
      owner = newOwner;
    }
  }

}

contract DBXTTest4 is Ownable,StandardToken {
    using SafeMath for uint256;

    string public name = "DBXTTest4";
    string public symbol = "DBXTTest4";
    uint256 public decimals = 18;
    uint256 public INITIAL_SUPPLY = 100000 * 1 ether;

    
    address public beneficiary;

    uint256 public priceETH;
    uint256 public priceDT;

    uint256 public weiRaised = 0;
    uint256 public investorCount = 0;

    uint public startTime;
    uint public endTime;

    bool public crowdsaleFinished = false;

    event Burn(address indexed from, uint256 value);
    event GoalReached(uint amountRaised);
    event NewContribution(address indexed holder, uint256 tokenAmount, uint256 etherAmount);

    modifier onlyAfter(uint time) {
        require(now > time);
        _;
    }

    modifier onlyBefore(uint time) {
        require(now < time);
        _;
    }

    constructor (
        address _beneficiary,
        uint256 _priceETH,
        uint256 _priceDT,
        uint _startTime,
        uint _duration) public {
        totalSupply = INITIAL_SUPPLY;
        balances[msg.sender] = INITIAL_SUPPLY;
        beneficiary = _beneficiary;
        priceETH = _priceETH;
        priceDT = _priceDT;

        startTime = _startTime;
        endTime = _startTime + _duration * 1 weeks;
    }

    function () payable {
        require(msg.value >= 0.01 * 1 ether);
        doPurchase(msg.sender, msg.value);
    }

    function withdraw(uint256 _value) onlyOwner {
        beneficiary.transfer(_value);
    }

    function finishCrowdsale() onlyOwner {
        transfer(beneficiary, balanceOf(this));
        crowdsaleFinished = true;
    }

    function doPurchase(address _sender, uint256 _value) private onlyAfter(startTime) onlyBefore(endTime) {
        
        require(!crowdsaleFinished);

        uint256 dtCount = _value.mul(priceDT).div(priceETH);

        require(balanceOf(this) >= dtCount);

        if (balanceOf(_sender) == 0) investorCount++;

        transfer(_sender, dtCount);

        weiRaised = weiRaised.add(_value);

        emit NewContribution(_sender, dtCount, _value);

        if (balanceOf(this) == 0) {
            emit GoalReached(weiRaised);
        }
    }

    function burn(uint256 _value) returns (bool success) {
        require(balances[msg.sender] >= _value);
        balances[msg.sender] = balances[msg.sender].sub(_value);
        totalSupply = totalSupply.sub(_value);
        emit Burn(msg.sender, _value);
        return true;
  }
}