 

pragma solidity ^0.4.24;

 

 
contract ERC20Basic {
  function totalSupply() public view returns (uint256);
  function balanceOf(address _who) public view returns (uint256);
  function transfer(address _to, uint256 _value) public returns (bool);
  event Transfer(address indexed from, address indexed to, uint256 value);
}

 

 
contract ERC20 is ERC20Basic {
  function allowance(address _owner, address _spender)
    public view returns (uint256);

  function transferFrom(address _from, address _to, uint256 _value)
    public returns (bool);

  function approve(address _spender, uint256 _value) public returns (bool);
  event Approval(
    address indexed owner,
    address indexed spender,
    uint256 value
  );
}

 

 
contract DetailedERC20 is ERC20 {
  string public name;
  string public symbol;
  uint8 public decimals;

  constructor(string _name, string _symbol, uint8 _decimals) public {
    name = _name;
    symbol = _symbol;
    decimals = _decimals;
  }
}

 

 
library SafeMath {

   
  function mul(uint256 _a, uint256 _b) internal pure returns (uint256 c) {
     
     
     
    if (_a == 0) {
      return 0;
    }

    c = _a * _b;
    assert(c / _a == _b);
    return c;
  }

   
  function div(uint256 _a, uint256 _b) internal pure returns (uint256) {
     
     
     
    return _a / _b;
  }

   
  function sub(uint256 _a, uint256 _b) internal pure returns (uint256) {
    assert(_b <= _a);
    return _a - _b;
  }

   
  function add(uint256 _a, uint256 _b) internal pure returns (uint256 c) {
    c = _a + _b;
    assert(c >= _a);
    return c;
  }
}

 

 
contract BasicToken is ERC20Basic {
  using SafeMath for uint256;

  mapping(address => uint256) internal balances;

  uint256 internal totalSupply_;

   
  function totalSupply() public view returns (uint256) {
    return totalSupply_;
  }

   
  function transfer(address _to, uint256 _value) public returns (bool) {
    require(_value <= balances[msg.sender]);
    require(_to != address(0));

    balances[msg.sender] = balances[msg.sender].sub(_value);
    balances[_to] = balances[_to].add(_value);
    emit Transfer(msg.sender, _to, _value);
    return true;
  }

   
  function balanceOf(address _owner) public view returns (uint256) {
    return balances[_owner];
  }

}

 

 
contract StandardToken is ERC20, BasicToken {

  mapping (address => mapping (address => uint256)) internal allowed;


   
  function transferFrom(
    address _from,
    address _to,
    uint256 _value
  )
    public
    returns (bool)
  {
    require(_value <= balances[_from]);
    require(_value <= allowed[_from][msg.sender]);
    require(_to != address(0));

    balances[_from] = balances[_from].sub(_value);
    balances[_to] = balances[_to].add(_value);
    allowed[_from][msg.sender] = allowed[_from][msg.sender].sub(_value);
    emit Transfer(_from, _to, _value);
    return true;
  }

   
  function approve(address _spender, uint256 _value) public returns (bool) {
    allowed[msg.sender][_spender] = _value;
    emit Approval(msg.sender, _spender, _value);
    return true;
  }

   
  function allowance(
    address _owner,
    address _spender
   )
    public
    view
    returns (uint256)
  {
    return allowed[_owner][_spender];
  }

   
  function increaseApproval(
    address _spender,
    uint256 _addedValue
  )
    public
    returns (bool)
  {
    allowed[msg.sender][_spender] = (
      allowed[msg.sender][_spender].add(_addedValue));
    emit Approval(msg.sender, _spender, allowed[msg.sender][_spender]);
    return true;
  }

   
  function decreaseApproval(
    address _spender,
    uint256 _subtractedValue
  )
    public
    returns (bool)
  {
    uint256 oldValue = allowed[msg.sender][_spender];
    if (_subtractedValue >= oldValue) {
      allowed[msg.sender][_spender] = 0;
    } else {
      allowed[msg.sender][_spender] = oldValue.sub(_subtractedValue);
    }
    emit Approval(msg.sender, _spender, allowed[msg.sender][_spender]);
    return true;
  }

}

 

 
contract Ownable {
  address public owner;


  event OwnershipRenounced(address indexed previousOwner);
  event OwnershipTransferred(
    address indexed previousOwner,
    address indexed newOwner
  );


   
  constructor() public {
    owner = msg.sender;
  }

   
  modifier onlyOwner() {
    require(msg.sender == owner);
    _;
  }

   
  function renounceOwnership() public onlyOwner {
    emit OwnershipRenounced(owner);
    owner = address(0);
  }

   
  function transferOwnership(address _newOwner) public onlyOwner {
    _transferOwnership(_newOwner);
  }

   
  function _transferOwnership(address _newOwner) internal {
    require(_newOwner != address(0));
    emit OwnershipTransferred(owner, _newOwner);
    owner = _newOwner;
  }
}

 

 
contract MintableToken is StandardToken, Ownable {
  event Mint(address indexed to, uint256 amount);
  event MintFinished();

  bool public mintingFinished = false;


  modifier canMint() {
    require(!mintingFinished);
    _;
  }

  modifier hasMintPermission() {
    require(msg.sender == owner);
    _;
  }

   
  function mint(
    address _to,
    uint256 _amount
  )
    public
    hasMintPermission
    canMint
    returns (bool)
  {
    totalSupply_ = totalSupply_.add(_amount);
    balances[_to] = balances[_to].add(_amount);
    emit Mint(_to, _amount);
    emit Transfer(address(0), _to, _amount);
    return true;
  }

   
  function finishMinting() public onlyOwner canMint returns (bool) {
    mintingFinished = true;
    emit MintFinished();
    return true;
  }
}

 

 
library Roles {
  struct Role {
    mapping (address => bool) bearer;
  }

   
  function add(Role storage _role, address _addr)
    internal
  {
    _role.bearer[_addr] = true;
  }

   
  function remove(Role storage _role, address _addr)
    internal
  {
    _role.bearer[_addr] = false;
  }

   
  function check(Role storage _role, address _addr)
    internal
    view
  {
    require(has(_role, _addr));
  }

   
  function has(Role storage _role, address _addr)
    internal
    view
    returns (bool)
  {
    return _role.bearer[_addr];
  }
}

 

 
contract RBAC {
  using Roles for Roles.Role;

  mapping (string => Roles.Role) private roles;

  event RoleAdded(address indexed operator, string role);
  event RoleRemoved(address indexed operator, string role);

   
  function checkRole(address _operator, string _role)
    public
    view
  {
    roles[_role].check(_operator);
  }

   
  function hasRole(address _operator, string _role)
    public
    view
    returns (bool)
  {
    return roles[_role].has(_operator);
  }

   
  function addRole(address _operator, string _role)
    internal
  {
    roles[_role].add(_operator);
    emit RoleAdded(_operator, _role);
  }

   
  function removeRole(address _operator, string _role)
    internal
  {
    roles[_role].remove(_operator);
    emit RoleRemoved(_operator, _role);
  }

   
  modifier onlyRole(string _role)
  {
    checkRole(msg.sender, _role);
    _;
  }

   
   
   
   
   
   
   
   
   

   

   
   
}

 

 
contract RBACMintableToken is MintableToken, RBAC {
   
  string public constant ROLE_MINTER = "minter";

   
  modifier hasMintPermission() {
    checkRole(msg.sender, ROLE_MINTER);
    _;
  }

   
  function addMinter(address _minter) public onlyOwner {
    addRole(_minter, ROLE_MINTER);
  }

   
  function removeMinter(address _minter) public onlyOwner {
    removeRole(_minter, ROLE_MINTER);
  }
}

 

 
contract BurnableToken is BasicToken {

  event Burn(address indexed burner, uint256 value);

   
  function burn(uint256 _value) public {
    _burn(msg.sender, _value);
  }

  function _burn(address _who, uint256 _value) internal {
    require(_value <= balances[_who]);
     
     

    balances[_who] = balances[_who].sub(_value);
    totalSupply_ = totalSupply_.sub(_value);
    emit Burn(_who, _value);
    emit Transfer(_who, address(0), _value);
  }
}

 

 
library AddressUtils {

   
  function isContract(address _addr) internal view returns (bool) {
    uint256 size;
     
     
     
     
     
     
     
    assembly { size := extcodesize(_addr) }
    return size > 0;
  }

}

 

 
interface ERC165 {

   
  function supportsInterface(bytes4 _interfaceId)
    external
    view
    returns (bool);
}

 

 
contract SupportsInterfaceWithLookup is ERC165 {

  bytes4 public constant InterfaceId_ERC165 = 0x01ffc9a7;
   

   
  mapping(bytes4 => bool) internal supportedInterfaces;

   
  constructor()
    public
  {
    _registerInterface(InterfaceId_ERC165);
  }

   
  function supportsInterface(bytes4 _interfaceId)
    external
    view
    returns (bool)
  {
    return supportedInterfaces[_interfaceId];
  }

   
  function _registerInterface(bytes4 _interfaceId)
    internal
  {
    require(_interfaceId != 0xffffffff);
    supportedInterfaces[_interfaceId] = true;
  }
}

 

 
contract ERC1363 is ERC20, ERC165 {
   

   

   
  function transferAndCall(address _to, uint256 _value) public returns (bool);

   
  function transferAndCall(address _to, uint256 _value, bytes _data) public returns (bool);  

   
  function transferFromAndCall(address _from, address _to, uint256 _value) public returns (bool);  


   
  function transferFromAndCall(address _from, address _to, uint256 _value, bytes _data) public returns (bool);  

   
  function approveAndCall(address _spender, uint256 _value) public returns (bool);  

   
  function approveAndCall(address _spender, uint256 _value, bytes _data) public returns (bool);  
}

 

 
contract ERC1363Receiver {
   

   
  function onTransferReceived(address _operator, address _from, uint256 _value, bytes _data) external returns (bytes4);  
}

 

 
contract ERC1363Spender {
   

   
  function onApprovalReceived(address _owner, uint256 _value, bytes _data) external returns (bytes4);  
}

 

 






 
contract ERC1363BasicToken is SupportsInterfaceWithLookup, ERC1363 {  
  using AddressUtils for address;

   
  bytes4 internal constant InterfaceId_ERC1363Transfer = 0x4bbee2df;

   
  bytes4 internal constant InterfaceId_ERC1363Approve = 0xfb9ec8ce;

   
   
  bytes4 private constant ERC1363_RECEIVED = 0x88a7ca5c;

   
   
  bytes4 private constant ERC1363_APPROVED = 0x7b04a2d0;

  constructor() public {
     
    _registerInterface(InterfaceId_ERC1363Transfer);
    _registerInterface(InterfaceId_ERC1363Approve);
  }

  function transferAndCall(
    address _to,
    uint256 _value
  )
    public
    returns (bool)
  {
    return transferAndCall(_to, _value, "");
  }

  function transferAndCall(
    address _to,
    uint256 _value,
    bytes _data
  )
    public
    returns (bool)
  {
    require(transfer(_to, _value));
    require(
      checkAndCallTransfer(
        msg.sender,
        _to,
        _value,
        _data
      )
    );
    return true;
  }

  function transferFromAndCall(
    address _from,
    address _to,
    uint256 _value
  )
    public
    returns (bool)
  {
     
    return transferFromAndCall(_from, _to, _value, "");
  }

  function transferFromAndCall(
    address _from,
    address _to,
    uint256 _value,
    bytes _data
  )
    public
    returns (bool)
  {
    require(transferFrom(_from, _to, _value));
    require(
      checkAndCallTransfer(
        _from,
        _to,
        _value,
        _data
      )
    );
    return true;
  }

  function approveAndCall(
    address _spender,
    uint256 _value
  )
    public
    returns (bool)
  {
    return approveAndCall(_spender, _value, "");
  }

  function approveAndCall(
    address _spender,
    uint256 _value,
    bytes _data
  )
    public
    returns (bool)
  {
    approve(_spender, _value);
    require(
      checkAndCallApprove(
        _spender,
        _value,
        _data
      )
    );
    return true;
  }

   
  function checkAndCallTransfer(
    address _from,
    address _to,
    uint256 _value,
    bytes _data
  )
    internal
    returns (bool)
  {
    if (!_to.isContract()) {
      return false;
    }
    bytes4 retval = ERC1363Receiver(_to).onTransferReceived(
      msg.sender, _from, _value, _data
    );
    return (retval == ERC1363_RECEIVED);
  }

   
  function checkAndCallApprove(
    address _spender,
    uint256 _value,
    bytes _data
  )
    internal
    returns (bool)
  {
    if (!_spender.isContract()) {
      return false;
    }
    bytes4 retval = ERC1363Spender(_spender).onApprovalReceived(
      msg.sender, _value, _data
    );
    return (retval == ERC1363_APPROVED);
  }
}

 

contract TokenRecover is Ownable {

   
  function transferAnyERC20Token(
    address _tokenAddress,
    uint256 _tokens
  )
  public
  onlyOwner
  returns (bool success)
  {
    return ERC20Basic(_tokenAddress).transfer(owner, _tokens);
  }
}

 

contract GastroAdvisorToken is DetailedERC20, RBACMintableToken, BurnableToken, ERC1363BasicToken, TokenRecover {  

  modifier canTransfer() {
    require(mintingFinished);
    _;
  }

  constructor()
  DetailedERC20("GastroAdvisorToken", "FORK", 18)
  ERC1363BasicToken()
  public
  {}

  function transfer(
    address _to,
    uint256 _value
  )
  public
  canTransfer
  returns (bool)
  {
    return super.transfer(_to, _value);
  }

  function transferFrom(
    address _from,
    address _to,
    uint256 _value
  )
  public
  canTransfer
  returns (bool)
  {
    return super.transferFrom(_from, _to, _value);
  }

   
  function addMinters(address[] _minters) public onlyOwner {
    require(_minters.length > 0);
    for (uint i = 0; i < _minters.length; i++) {
      addRole(_minters[i], ROLE_MINTER);
    }
  }
}