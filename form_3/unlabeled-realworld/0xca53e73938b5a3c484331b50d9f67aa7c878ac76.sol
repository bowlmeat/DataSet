 

 
library SafeMathLib {

  function times(uint a, uint b) returns (uint) {
    uint c = a * b;
    assert(a == 0 || c / a == b);
    return c;
  }

  function minus(uint a, uint b) returns (uint) {
    assert(b <= a);
    return a - b;
  }

  function plus(uint a, uint b) returns (uint) {
    uint c = a + b;
    assert(c>=a && c>=b);
    return c;
  }

  function assert(bool assertion) private {
    if (!assertion) throw;
  }
}




 
contract Ownable {
  address public owner;

  function Ownable() {
    owner = msg.sender;
  }

  modifier onlyOwner() {
    if (msg.sender != owner) {
      throw;
    }
    _;
  }

  function transferOwnership(address newOwner) onlyOwner {
    if (newOwner != address(0)) {
      owner = newOwner;
    }
  }

}


 
contract Haltable is Ownable {
  bool public halted;

  modifier stopInEmergency {
    if (halted) throw;
    _;
  }

  modifier onlyInEmergency {
    if (!halted) throw;
    _;
  }

   
  function halt() external onlyOwner {
    halted = true;
  }

   
  function unhalt() external onlyOwner onlyInEmergency {
    halted = false;
  }

}


 
contract PricingStrategy {

   
  function isPricingStrategy() public constant returns (bool) {
    return true;
  }

   
  function isSane(address crowdsale) public constant returns (bool) {
    return true;
  }

   
  function calculatePrice(uint value, uint tokensSold, uint weiRaised, address msgSender, uint decimals) public constant returns (uint tokenAmount);
}


 
contract FinalizeAgent {

  function isFinalizeAgent() public constant returns(bool) {
    return true;
  }

   
  function isSane() public constant returns (bool);

   
  function finalizeCrowdsale();

}




 
contract ERC20 {
  uint public totalSupply;
  function balanceOf(address who) constant returns (uint);
  function allowance(address owner, address spender) constant returns (uint);

  function transfer(address to, uint value) returns (bool ok);
  function transferFrom(address from, address to, uint value) returns (bool ok);
  function approve(address spender, uint value) returns (bool ok);
  event Transfer(address indexed from, address indexed to, uint value);
  event Approval(address indexed owner, address indexed spender, uint value);
}


 
contract FractionalERC20 is ERC20 {

  uint public decimals;

}



 
contract Crowdsale is Haltable {

  using SafeMathLib for uint;

   
  FractionalERC20 public token;

   
  PricingStrategy public pricingStrategy;

   
  FinalizeAgent public finalizeAgent;

   
  address public multisigWallet;

   
  uint public minimumFundingGoal;

   
  uint public startsAt;

   
  uint public endsAt;

   
  uint public tokensSold = 0;

   
  uint public weiRaised = 0;

   
  uint public investorCount = 0;

   
  uint public loadedRefund = 0;

   
  uint public weiRefunded = 0;

   
  bool public finalized;

   
  mapping (address => uint256) public investedAmountOf;

   
  mapping (address => uint256) public tokenAmountOf;

   
  uint public ownerTestValue;

   
  enum State{Unknown, Preparing, PreFunding, Funding, Success, Failure, Finalized, Refunding}

  event Invested(address investor, uint weiAmount, uint tokenAmount);
  event Refund(address investor, uint weiAmount);

  function Crowdsale(address _token, PricingStrategy _pricingStrategy, address _multisigWallet, uint _start, uint _end, uint _minimumFundingGoal) {

    owner = msg.sender;

    token = FractionalERC20(_token);

    setPricingStrategy(_pricingStrategy);

    multisigWallet = _multisigWallet;
    if(multisigWallet == 0) {
        throw;
    }

    if(_start == 0) {
        throw;
    }

    startsAt = _start;

    if(_end == 0) {
        throw;
    }

    endsAt = _end;

     
    if(startsAt >= endsAt) {
        throw;
    }

     
    minimumFundingGoal = _minimumFundingGoal;
  }

   
  function() payable {
    throw;
  }

   
  function invest(address receiver) inState(State.Funding) stopInEmergency payable public {

    uint weiAmount = msg.value;
    uint tokenAmount = pricingStrategy.calculatePrice(weiAmount, weiRaised, tokensSold, msg.sender, token.decimals());

    if(tokenAmount == 0) {
       
      throw;
    }

    if(investedAmountOf[receiver] == 0) {
        
       investorCount++;
    }

     
    investedAmountOf[receiver] = investedAmountOf[receiver].plus(weiAmount);
    tokenAmountOf[receiver] = tokenAmountOf[receiver].plus(tokenAmount);

     
    weiRaised = weiRaised.plus(weiAmount);
    tokensSold = tokensSold.plus(tokenAmount);

     
    if(isBreakingCap(tokenAmount, weiAmount, weiRaised, tokensSold)) {
      throw;
    }

    assignTokens(receiver, tokenAmount);

     
    if(!multisigWallet.send(weiAmount)) throw;

     
    Invested(receiver, weiAmount, tokenAmount);
  }

   
  function buy() public payable {
    invest(msg.sender);
  }

   
  function finalize() public inState(State.Success) onlyOwner stopInEmergency {

     
    if(finalized) {
      throw;
    }

     
    if(address(finalizeAgent) != 0) {
      finalizeAgent.finalizeCrowdsale();
    }

    finalized = true;
  }

   
  function setFinalizeAgent(FinalizeAgent addr) onlyOwner {
    finalizeAgent = addr;

     
    if(!finalizeAgent.isFinalizeAgent()) {
      throw;
    }
  }

   
  function setPricingStrategy(PricingStrategy _pricingStrategy) onlyOwner {
    pricingStrategy = _pricingStrategy;

     
    if(!pricingStrategy.isPricingStrategy()) {
      throw;
    }
  }

   
  function loadRefund() public payable inState(State.Failure) {
    if(msg.value == 0) throw;
    loadedRefund = loadedRefund.plus(msg.value);
  }

   
  function refund() public inState(State.Refunding) {
    uint256 weiValue = investedAmountOf[msg.sender];
    if (weiValue == 0) throw;
    investedAmountOf[msg.sender] = 0;
    weiRefunded = weiRefunded.plus(weiValue);
    Refund(msg.sender, weiValue);
    if (!msg.sender.send(weiValue)) throw;
  }

   
  function isMinimumGoalReached() public constant returns (bool reached) {
    return weiRaised >= minimumFundingGoal;
  }

   
  function getState() public constant returns (State) {
    if(finalized) return State.Finalized;
    else if (address(finalizeAgent) == 0) return State.Preparing;
    else if (!finalizeAgent.isSane()) return State.Preparing;
    else if (!pricingStrategy.isSane(address(this))) return State.Preparing;
    else if (block.timestamp < startsAt) return State.PreFunding;
    else if (block.timestamp <= endsAt && !isCrowdsaleFull()) return State.Funding;
    else if (isMinimumGoalReached()) return State.Success;
    else if (!isMinimumGoalReached() && weiRaised > 0 && loadedRefund >= weiRaised) return State.Refunding;
    else return State.Failure;
  }

   
  function setOwnerTestValue(uint val) onlyOwner {
    ownerTestValue = val;
  }

   
   
   

   
  modifier inState(State state) {
    if(getState() != state) throw;
    _;
  }


   
   
   

   
  function isBreakingCap(uint weiAmount, uint tokenAmount, uint weiRaisedTotal, uint tokensSoldTotal) constant returns (bool limitBroken);

   
  function isCrowdsaleFull() public constant returns (bool);

   
  function assignTokens(address receiver, uint tokenAmount) private;
}








 
contract SafeMath {
  function safeMul(uint a, uint b) internal returns (uint) {
    uint c = a * b;
    assert(a == 0 || c / a == b);
    return c;
  }

  function safeDiv(uint a, uint b) internal returns (uint) {
    assert(b > 0);
    uint c = a / b;
    assert(a == b * c + a % b);
    return c;
  }

  function safeSub(uint a, uint b) internal returns (uint) {
    assert(b <= a);
    return a - b;
  }

  function safeAdd(uint a, uint b) internal returns (uint) {
    uint c = a + b;
    assert(c>=a && c>=b);
    return c;
  }

  function max64(uint64 a, uint64 b) internal constant returns (uint64) {
    return a >= b ? a : b;
  }

  function min64(uint64 a, uint64 b) internal constant returns (uint64) {
    return a < b ? a : b;
  }

  function max256(uint256 a, uint256 b) internal constant returns (uint256) {
    return a >= b ? a : b;
  }

  function min256(uint256 a, uint256 b) internal constant returns (uint256) {
    return a < b ? a : b;
  }

  function assert(bool assertion) internal {
    if (!assertion) {
      throw;
    }
  }
}



 
contract StandardToken is ERC20, SafeMath {

  mapping(address => uint) balances;
  mapping (address => mapping (address => uint)) allowed;

  function transfer(address _to, uint _value) returns (bool success) {
    balances[msg.sender] = safeSub(balances[msg.sender], _value);
    balances[_to] = safeAdd(balances[_to], _value);
    Transfer(msg.sender, _to, _value);
    return true;
  }

  function transferFrom(address _from, address _to, uint _value) returns (bool success) {
    var _allowance = allowed[_from][msg.sender];

     
     

    balances[_to] = safeAdd(balances[_to], _value);
    balances[_from] = safeSub(balances[_from], _value);
    allowed[_from][msg.sender] = safeSub(_allowance, _value);
    Transfer(_from, _to, _value);
    return true;
  }

  function balanceOf(address _owner) constant returns (uint balance) {
    return balances[_owner];
  }

  function approve(address _spender, uint _value) returns (bool success) {
    allowed[msg.sender][_spender] = _value;
    Approval(msg.sender, _spender, _value);
    return true;
  }

  function allowance(address _owner, address _spender) constant returns (uint remaining) {
    return allowed[_owner][_spender];
  }

}




 
contract MintableToken is StandardToken, Ownable {

  using SafeMathLib for uint;

  bool public mintingFinished = false;

   
  mapping (address => bool) public mintAgents;

   
  function mint(address receiver, uint amount) onlyMintAgent canMint public {
    totalSupply = totalSupply.plus(amount);
    balances[receiver] = balances[receiver].plus(amount);
    Transfer(0, receiver, amount);
  }

   
  function setMintAgent(address addr, bool state) onlyOwner canMint public {
    mintAgents[addr] = state;
  }

  modifier onlyMintAgent() {
     
    if(!mintAgents[msg.sender]) {
        throw;
    }
    _;
  }

   
  modifier canMint() {
    if(mintingFinished) throw;
    _;
  }
}


 
contract MintedTokenCappedCrowdsale is Crowdsale {

   
  uint public maximumSellableTokens;

  function MintedTokenCappedCrowdsale(address _token, PricingStrategy _pricingStrategy, address _multisigWallet, uint _start, uint _end, uint _minimumFundingGoal, uint _maximumSellableTokens) Crowdsale(_token, _pricingStrategy, _multisigWallet, _start, _end, _minimumFundingGoal) {
    maximumSellableTokens = _maximumSellableTokens;
  }

   
  function isBreakingCap(uint weiAmount, uint tokenAmount, uint weiRaisedTotal, uint tokensSoldTotal) constant returns (bool limitBroken) {
    return tokensSoldTotal > maximumSellableTokens;
  }

  function isCrowdsaleFull() public constant returns (bool) {
    return tokensSold >= maximumSellableTokens;
  }

   
  function assignTokens(address receiver, uint tokenAmount) private {
    MintableToken mintableToken = MintableToken(token);
    mintableToken.mint(receiver, tokenAmount);
  }
}



 
contract RelaunchedCrowdsale is MintedTokenCappedCrowdsale {

   
  event RestoredInvestment(address addr, uint originalTxHash);

  mapping(uint => bool) public reissuedTransactions;

  function RelaunchedCrowdsale(address _token, PricingStrategy _pricingStrategy, address _multisigWallet, uint _start, uint _end, uint _minimumFundingGoal, uint _maximumSellableTokens) MintedTokenCappedCrowdsale(_token, _pricingStrategy, _multisigWallet, _start, _end, _minimumFundingGoal, _maximumSellableTokens) {
  }

   
  function getRestoredTransactionStatus(uint _originalTxHash) public constant returns(bool) {
    return reissuedTransactions[_originalTxHash];
  }

   
  function setInvestorData(address _addr, uint _weiAmount, uint _tokenAmount, uint _originalTxHash) onlyOwner public {

    if(investedAmountOf[_addr] == 0) {
      investorCount++;
    }

    investedAmountOf[_addr] += _weiAmount;
    tokenAmountOf[_addr] += _tokenAmount;

    weiRaised += _weiAmount;
    tokensSold += _tokenAmount;

    Invested(_addr, _weiAmount, _tokenAmount);
    RestoredInvestment(_addr, _originalTxHash);
  }

   
  function setInvestorDataAndIssueNewToken(address _addr, uint _weiAmount, uint _tokenAmount, uint _originalTxHash) onlyOwner public {

     
    if(reissuedTransactions[_originalTxHash]) {
      throw;
    }

    setInvestorData(_addr, _weiAmount, _tokenAmount, _originalTxHash);

     
    if(isBreakingCap(_tokenAmount, _weiAmount, weiRaised, tokensSold)) {
      throw;
    }

     
    reissuedTransactions[_originalTxHash] = true;

     
    MintableToken mintableToken = MintableToken(token);
    mintableToken.mint(_addr, _tokenAmount);
  }

}