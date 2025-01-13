 

pragma solidity ^0.4.17;

 

 
contract Ownable {
  address public owner;

  event OwnershipTransferred(address indexed previousOwner, address indexed newOwner);

   
  function Ownable() public {
    owner = msg.sender;
  }

   
  modifier onlyOwner() {
    require(msg.sender == owner);
    _;
  }

   
  function transferOwnership(address newOwner) public onlyOwner {
    require(newOwner != address(0));
    OwnershipTransferred(owner, newOwner);
    owner = newOwner;
  }

}

 

 
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

 

contract ERC20Interface {

  event Transfer(address indexed from, address indexed to, uint256 value);
  event Approval(address indexed owner, address indexed spender, uint256 value);

  function totalSupply() public view returns (uint256);
  function balanceOf(address who) public view returns (uint256);
  function transfer(address to, uint256 value) public returns (bool);

  function approve(address spender, uint256 value) public returns (bool);
  function transferFrom(address from, address to, uint256 value) public returns (bool);
  function allowance(address owner, address spender) public view returns (uint256);

}

 

contract BaseToken is ERC20Interface {
  using SafeMath for uint256;

  mapping(address => uint256) balances;
  mapping (address => mapping (address => uint256)) internal allowed;

  uint256 totalSupply_;

   
  function totalSupply() public view returns (uint256) {
    return totalSupply_;
  }

   
  function balanceOf(address _owner) public view returns (uint256 balance) {
    return balances[_owner];
  }

   
  function transfer(address _to, uint256 _value) public returns (bool) {
    require(_to != address(0));
    require(_value <= balances[msg.sender]);

     
    balances[msg.sender] = balances[msg.sender].sub(_value);
    balances[_to] = balances[_to].add(_value);
    Transfer(msg.sender, _to, _value);

    return true;
  }

   
  function approve(address _spender, uint256 _value) public returns (bool) {
    require(_spender != address(0));

    allowed[msg.sender][_spender] = _value;
    Approval(msg.sender, _spender, _value);

    return true;
  }

   
  function transferFrom(address _from, address _to, uint256 _value) public returns (bool) {
    require(_to != address(0));
    require(_value <= balances[_from]);
    require(_value <= allowed[_from][msg.sender]);

    balances[_from] = balances[_from].sub(_value);
    balances[_to] = balances[_to].add(_value);
    allowed[_from][msg.sender] = allowed[_from][msg.sender].sub(_value);

    Transfer(_from, _to, _value);

    return true;
  }

   
  function allowance(address _owner, address _spender) public view returns (uint256) {
    return allowed[_owner][_spender];
  }

   
  function increaseApproval(address _spender, uint256 _addedValue) public returns (bool) {
    allowed[msg.sender][_spender] = allowed[msg.sender][_spender].add(_addedValue);
    Approval(msg.sender, _spender, allowed[msg.sender][_spender]);

    return true;
  }

   
  function decreaseApproval(address _spender, uint256 _subtractedValue) public returns (bool) {
    uint oldValue = allowed[msg.sender][_spender];
    if (_subtractedValue > oldValue) {
      allowed[msg.sender][_spender] = 0;
    } else {
      allowed[msg.sender][_spender] = oldValue.sub(_subtractedValue);
    }
    Approval(msg.sender, _spender, allowed[msg.sender][_spender]);
    return true;
  }

}

 

 
contract MintableToken is BaseToken, Ownable {

  event Mint(address indexed to, uint256 amount);
  event MintFinished();

  bool public mintingFinished = false;

  modifier canMint() {
    require(!mintingFinished);
    _;
  }

   
  function mint(address _to, uint256 _amount) onlyOwner canMint public returns (bool) {
    require(_to != address(0));

    totalSupply_ = totalSupply_.add(_amount);
    balances[_to] = balances[_to].add(_amount);
    Mint(_to, _amount);
    Transfer(address(0), _to, _amount);
    return true;
  }

   
  function finishMinting() onlyOwner canMint public returns (bool) {
    mintingFinished = true;
    MintFinished();
    return true;
  }

}

 

contract CappedToken is MintableToken {

  uint256 public cap;

  function CappedToken(uint256 _cap) public {
    require(_cap > 0);
    cap = _cap;
  }

  function mint(address _to, uint256 _amount) onlyOwner canMint public returns (bool) {
    require(totalSupply_.add(_amount) <= cap);

    return super.mint(_to, _amount);
  }

}

 

 
contract Pausable is Ownable {
  event Pause();
  event Unpause();

  bool public paused = false;

   
  modifier whenNotPaused() {
    require(!paused);
    _;
  }

   
  modifier whenPaused() {
    require(paused);
    _;
  }

   
  function pause() onlyOwner whenNotPaused public {
    paused = true;
    Pause();
  }

   
  function unpause() onlyOwner whenPaused public {
    paused = false;
    Unpause();
  }

}

 

 
contract PausableToken is BaseToken, Pausable {

  function transfer(address _to, uint256 _value) public whenNotPaused returns (bool) {
    return super.transfer(_to, _value);
  }

  function transferFrom(address _from, address _to, uint256 _value) public whenNotPaused returns (bool) {
    return super.transferFrom(_from, _to, _value);
  }

  function approve(address _spender, uint256 _value) public whenNotPaused returns (bool) {
    return super.approve(_spender, _value);
  }

  function increaseApproval(address _spender, uint _addedValue) public whenNotPaused returns (bool success) {
    return super.increaseApproval(_spender, _addedValue);
  }

  function decreaseApproval(address _spender, uint _subtractedValue) public whenNotPaused returns (bool success) {
    return super.decreaseApproval(_spender, _subtractedValue);
  }
}

 

 
contract SignedTransferToken is BaseToken {

  event TransferPreSigned(
    address indexed from,
    address indexed to,
    address indexed settler,
    uint256 value,
    uint256 fee
  );

  event TransferPreSignedMany(
    address indexed from,
    address indexed settler,
    uint256 value,
    uint256 fee
  );


   
  mapping(address => mapping(bytes32 => bool)) executedSettlements;

   
  function transferPreSigned(address _from,
                             address _to,
                             uint256 _value,
                             uint256 _fee,
                             uint256 _nonce,
                             uint8 _v,
                             bytes32 _r,
                             bytes32 _s) public returns (bool) {
    uint256 total = _value.add(_fee);
    bytes32 calcHash = calculateHash(_from, _to, _value, _fee, _nonce);

    require(_to != address(0));
    require(isValidSignature(_from, calcHash, _v, _r, _s));
    require(balances[_from] >= total);
    require(!executedSettlements[_from][calcHash]);

    executedSettlements[_from][calcHash] = true;

     
    balances[_from] = balances[_from].sub(_value);
    balances[_to] = balances[_to].add(_value);
    Transfer(_from, _to, _value);

     
    balances[_from] = balances[_from].sub(_fee);
    balances[msg.sender] = balances[msg.sender].add(_fee);
    Transfer(_from, msg.sender, _fee);

    TransferPreSigned(_from, _to, msg.sender, _value, _fee);

    return true;
  }

   
  function transferPreSignedBulk(address[] _from,
                                 address[] _to,
                                 uint256[] _values,
                                 uint256[] _fees,
                                 uint256[] _nonces,
                                 uint8[] _v,
                                 bytes32[] _r,
                                 bytes32[] _s) public returns (bool) {
     
    require(_from.length == _to.length &&
            _to.length ==_values.length &&
            _values.length == _fees.length &&
            _fees.length == _nonces.length &&
            _nonces.length == _v.length &&
            _v.length == _r.length &&
            _r.length == _s.length);

    for(uint i; i < _from.length; i++) {
      transferPreSigned(_from[i],
                        _to[i],
                        _values[i],
                        _fees[i],
                        _nonces[i],
                        _v[i],
                        _r[i],
                        _s[i]);
    }

    return true;
  }


  function transferPreSignedMany(address _from,
                                 address[] _tos,
                                 uint256[] _values,
                                 uint256 _fee,
                                 uint256 _nonce,
                                 uint8 _v,
                                 bytes32 _r,
                                 bytes32 _s) public returns (bool) {
   require(_tos.length == _values.length);
   uint256 total = getTotal(_tos, _values, _fee);

   bytes32 calcHash = calculateManyHash(_from, _tos, _values, _fee, _nonce);

   require(isValidSignature(_from, calcHash, _v, _r, _s));
   require(balances[_from] >= total);
   require(!executedSettlements[_from][calcHash]);

   executedSettlements[_from][calcHash] = true;

    
   for(uint i; i < _tos.length; i++) {
      
     balances[_from] = balances[_from].sub(_values[i]);
     balances[_tos[i]] = balances[_tos[i]].add(_values[i]);
     Transfer(_from, _tos[i], _values[i]);
   }

    
   balances[_from] = balances[_from].sub(_fee);
   balances[msg.sender] = balances[msg.sender].add(_fee);
   Transfer(_from, msg.sender, _fee);

   TransferPreSignedMany(_from, msg.sender, total, _fee);

   return true;
  }

  function getTotal(address[] _tos, uint256[] _values, uint256 _fee) private view returns (uint256)  {
    uint256 total = _fee;

    for(uint i; i < _tos.length; i++) {
      total = total.add(_values[i]);  
      require(_tos[i] != address(0));  
    }

    return total;
  }

   
  function calculateManyHash(address _from, address[] _tos, uint256[] _values, uint256 _fee, uint256 _nonce) public view returns (bytes32) {
    return keccak256(uint256(1), address(this), _from, _tos, _values, _fee, _nonce);
  }

   
  function calculateHash(address _from, address _to, uint256 _value, uint256 _fee, uint256 _nonce) public view returns (bytes32) {
    return keccak256(uint256(0), address(this), _from, _to, _value, _fee, _nonce);
  }

   
  function isValidSignature(address _signer, bytes32 _hash, uint8 _v, bytes32 _r, bytes32 _s) public pure returns (bool) {
    return _signer == ecrecover(
            keccak256("\x19Ethereum Signed Message:\n32", _hash),
            _v,
            _r,
            _s
        );
  }

   
  function isTransactionAlreadySettled(address _from, bytes32 _calcHash) public view returns (bool) {
    return executedSettlements[_from][_calcHash];
  }

}

 

contract PausableSignedTransferToken is SignedTransferToken, PausableToken {

  function transferPreSigned(address _from,
                             address _to,
                             uint256 _value,
                             uint256 _fee,
                             uint256 _nonce,
                             uint8 _v,
                             bytes32 _r,
                             bytes32 _s) public whenNotPaused returns (bool) {
    return super.transferPreSigned(_from, _to, _value, _fee, _nonce, _v, _r, _s);
  }

  function transferPreSignedBulk(address[] _from,
                                 address[] _to,
                                 uint256[] _values,
                                 uint256[] _fees,
                                 uint256[] _nonces,
                                 uint8[] _v,
                                 bytes32[] _r,
                                 bytes32[] _s) public whenNotPaused returns (bool) {
    return super.transferPreSignedBulk(_from, _to, _values, _fees, _nonces, _v, _r, _s);
  }

  function transferPreSignedMany(address _from,
                                 address[] _tos,
                                 uint256[] _values,
                                 uint256 _fee,
                                 uint256 _nonce,
                                 uint8 _v,
                                 bytes32 _r,
                                 bytes32 _s) public whenNotPaused returns (bool) {
    return super.transferPreSignedMany(_from, _tos, _values, _fee, _nonce, _v, _r, _s);
  }
}

 

contract FourToken is CappedToken, PausableSignedTransferToken  {
  string public name = 'The 4th Pillar Token';
  string public symbol = 'FOUR';
  uint256 public decimals = 18;

   
  uint256 public maxSupply = 400000000 * 10**decimals;

  function FourToken()
    CappedToken(maxSupply) public {
      paused = true;
  }

   
  function recoverERC20Tokens(address _erc20, uint256 _amount) public onlyOwner {
    ERC20Interface(_erc20).transfer(msg.sender, _amount);
  }

}

 

 
contract Crowdsale {
  using SafeMath for uint256;

   
  event TokenPurchase(address indexed purchaser, address indexed beneficiary, uint256 value, uint256 tokens);

   
  MintableToken public token;

   
  uint256 public startTime;
  uint256 public endTime;

   
  uint256 public rate;

   
  address public wallet;

   
  uint256 public weiRaised;
   
  uint256 public tokensSold;


  function Crowdsale(uint256 _startTime, uint256 _endTime, uint256 _rate, address _wallet, address _token) public {
    require(_startTime >= now);
    require(_endTime >= _startTime);
    require(_rate > 0);
    require(_wallet != address(0));
    require(_token != address(0));

    startTime = _startTime;
    endTime = _endTime;
    rate = _rate;
    wallet = _wallet;
    token = MintableToken(_token);
  }

   
  function () external payable {
    buyTokens(msg.sender);
  }

   
  function buyTokens(address beneficiary) public payable {
    require(beneficiary != address(0));
    require(validPurchase());

    uint256 weiAmount = msg.value;

     
    uint256 tokens = getTokenAmount(weiAmount);

     
    weiRaised = weiRaised.add(weiAmount);
    tokensSold = tokensSold.add(tokens);

    token.mint(beneficiary, tokens);
    TokenPurchase(msg.sender, beneficiary, weiAmount, tokens);

    forwardFunds();
  }

   
  function hasEnded() public view returns (bool) {
    return now > endTime;
  }

   
  function getTokenAmount(uint256 weiAmount) internal view returns(uint256) {
    return weiAmount.mul(rate);
  }

   
   
  function forwardFunds() internal {
    wallet.transfer(msg.value);
  }

   
  function validPurchase() internal view returns (bool) {
    bool withinPeriod = now >= startTime && now <= endTime;
    bool nonZeroPurchase = msg.value != 0;
    return withinPeriod && nonZeroPurchase;
  }

}

 

contract FinalizableCrowdsale is Crowdsale, Ownable {
  using SafeMath for uint256;

  event Finalized();

  bool public isFinalized = false;

   
  function finalize() onlyOwner public {
    require(!isFinalized);
    require(hasEnded());

    finalization();
    Finalized();

    isFinalized = true;
  }

   
  function finalization() internal {
  }

}

 

contract TokenCappedCrowdsale is Crowdsale {
  using SafeMath for uint256;

  uint256 public tokenCap;

  function TokenCappedCrowdsale(uint256 _tokenCap) public {
    require(_tokenCap > 0);
    tokenCap = _tokenCap;
  }

  function isCapReached() public view returns (bool) {
    return tokensSold >= tokenCap;
  }

  function hasEnded() public view returns (bool) {
    return isCapReached() || super.hasEnded();
  }

   
   
  function validPurchase() internal view returns (bool) {
    bool withinCap = tokensSold.add(getTokenAmount(msg.value)) <= tokenCap;
    return withinCap && super.validPurchase();
  }
}

 

contract WhitelistCrowdsale is Crowdsale, Ownable {
  using SafeMath for uint256;

  event WhitelistUpdated(uint256 timestamp, string operation, uint256 totalAddresses);

   
  mapping(address => bool) whitelisted;

   
  uint256 public whitelistedCount;

  function isWhitelisted(address _addr) public view returns (bool) {
    return whitelisted[_addr];
  }

  function addAddress(address _addr) external onlyOwner {
    whitelisted[_addr] = true;
    whitelistedCount++;
    WhitelistUpdated(block.timestamp, "Added", whitelistedCount);
  }

  function addAddresses(address[] _addrs) external onlyOwner {
    for (uint256 i = 0; i < _addrs.length; i++) {
      whitelisted[_addrs[i]] = true;
      whitelistedCount++;
    }

    WhitelistUpdated(block.timestamp, "Added", whitelistedCount);
  }

  function removeAddress(address _addr) external onlyOwner {
    whitelisted[_addr] = false;
    whitelistedCount--;
    WhitelistUpdated(block.timestamp, "Removed", whitelistedCount);
  }

  function removeAddresses(address[] _addrs) external onlyOwner {
    for (uint256 i = 0; i < _addrs.length; i++) {
      whitelisted[_addrs[i]] = false;
      whitelistedCount--;
    }

    WhitelistUpdated(block.timestamp, "Removed", whitelistedCount);
  }

  function validPurchase() internal view returns (bool) {
    return isWhitelisted(msg.sender) && super.validPurchase();
  }

}

 

contract FourCrowdsale is TokenCappedCrowdsale, WhitelistCrowdsale, FinalizableCrowdsale {
  event RateChanged(uint256 newRate, string name);

  uint256 private constant E18 = 10**18;

   
  uint256 private TOKEN_SALE_CAP = 152000000 * E18;

  uint256 public constant TEAM_TOKENS = 50000000 * E18;
  address public constant TEAM_ADDRESS = 0x3EC2fC20c04656F4B0AA7372258A36FAfB1EF427;

   
 
 

  uint256 public constant ADVISORS_AND_CONTRIBUTORS_TOKENS = 39000000 * E18;
  address public constant ADVISORS_AND_CONTRIBUTORS_ADDRESS = 0x90adab6891514DC24411B9Adf2e11C0eD7739999;

   
 
 

   
  address public constant UNSOLD_ADDRESS = 0x4eC155995211C8639375Ae3106187bff3FF5DB46;

   
  uint256 public bonus;

  function FourCrowdsale(uint256 _startTime,
                         uint256 _endTime,
                         uint256 _rate,
                         uint256 _bonus,
                         address _wallet,
                         address _token)
        TokenCappedCrowdsale(TOKEN_SALE_CAP)
        Crowdsale(_startTime, _endTime, _rate, _wallet, _token) public {
    bonus = _bonus;
  }

  function setCrowdsaleWallet(address _wallet) public onlyOwner {
    require(_wallet != address(0));
    wallet = _wallet;
  }

  function changeStartAndEndTime(uint256 _newStartTime, uint256 _newEndTime) public onlyOwner {
    require(_newStartTime >= now);
    require(_newEndTime >= _newStartTime);

    startTime = _newStartTime;
    endTime = _newEndTime;
  }

  function changeEndTime(uint256 _newEndTime) public onlyOwner {
    require(_newEndTime > startTime);
    endTime = _newEndTime;
  }

  function setRate(uint256 _rate) public onlyOwner  {
    require(now < startTime);  
    rate = _rate;
    RateChanged(_rate, 'rate');
  }

  function setBonus(uint256 _bonus) public onlyOwner  {
    require(now < startTime);  
    bonus = _bonus;
    RateChanged(_bonus, 'bonus');
  }

  function processPresaleOrEarlyContributors(address[] _beneficiaries, uint256[] _tokenAmounts) public onlyOwner {
     
    require(now <= endTime);

    for (uint i = 0; i < _beneficiaries.length; i++) {
       
      tokensSold = tokensSold.add(_tokenAmounts[i]);
      token.mint(_beneficiaries[i], _tokenAmounts[i]);

      TokenPurchase(msg.sender, _beneficiaries[i], 0, _tokenAmounts[i]);
    }
  }


  function getTokenAmount(uint256 weiAmount) internal view returns(uint256) {
    uint256 actualRate = rate;

     
    if (now <= startTime + 1 days) {
      actualRate = actualRate.add(bonus);
    }

    return weiAmount.mul(actualRate);
  }

  function finalization() internal {
     
    token.mint(TEAM_ADDRESS, TEAM_TOKENS);

     
     
     

     
    token.mint(ADVISORS_AND_CONTRIBUTORS_ADDRESS, ADVISORS_AND_CONTRIBUTORS_TOKENS);

     
     
     

     
    uint256 unsold_tokens = TOKEN_SALE_CAP - tokensSold;
    token.mint(UNSOLD_ADDRESS, unsold_tokens);

     
    token.finishMinting();
     
    token.transferOwnership(owner);
     
    super.finalization();
  }

   
  function recoverERC20Tokens(address _erc20, uint256 _amount) public onlyOwner {
    ERC20Interface(_erc20).transfer(msg.sender, _amount);
  }

  function releaseTokenOwnership() public onlyOwner {
    token.transferOwnership(owner);
  }
}