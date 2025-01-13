 

pragma solidity 0.4.18;

 
 
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

  function toInt256Safe(uint256 a) internal pure returns (int256) {
    int256 b = int256(a);
    assert(b >= 0);
    return b;
  }
}

 
library SafeMathInt {
  function mul(int256 a, int256 b) internal pure returns (int256) {
     
     
    assert(!(a == - 2**255 && b == -1) && !(b == - 2**255 && a == -1));

    int256 c = a * b;
    assert((b == 0) || (c / b == a));
    return c;
  }

  function div(int256 a, int256 b) internal pure returns (int256) {
     
     
    assert(!(a == - 2**255 && b == -1));

     
    int256 c = a / b;
     
    return c;
  }

  function sub(int256 a, int256 b) internal pure returns (int256) {
    assert((b >= 0 && a - b <= a) || (b < 0 && a - b > a));

    return a - b;
  }

  function add(int256 a, int256 b) internal pure returns (int256) {
    int256 c = a + b;
    assert((b >= 0 && c >= a) || (b < 0 && c < a));
    return c;
  }

  function toUint256Safe(int256 a) internal pure returns (uint256) {
    assert(a>=0);
    return uint256(a);
  }
}


 
library SafeMathUint96 {
  function mul(uint96 a, uint96 b) internal pure returns (uint96) {
    uint96 c = a * b;
    assert(a == 0 || c / a == b);
    return c;
  }

  function div(uint96 a, uint96 b) internal pure returns (uint96) {
     
    uint96 c = a / b;
     
    return c;
  }

  function sub(uint96 a, uint96 b) internal pure returns (uint96) {
    assert(b <= a);
    return a - b;
  }

  function add(uint96 a, uint96 b) internal pure returns (uint96) {
    uint96 c = a + b;
    assert(c >= a);
    return c;
  }
}


 
library SafeMathUint8 {
  function mul(uint8 a, uint8 b) internal pure returns (uint8) {
    uint8 c = a * b;
    assert(a == 0 || c / a == b);
    return c;
  }

  function div(uint8 a, uint8 b) internal pure returns (uint8) {
     
    uint8 c = a / b;
     
    return c;
  }

  function sub(uint8 a, uint8 b) internal pure returns (uint8) {
    assert(b <= a);
    return a - b;
  }

  function add(uint8 a, uint8 b) internal pure returns (uint8) {
    uint8 c = a + b;
    assert(c >= a);
    return c;
  }
}


 
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


   
  function transferOwnership(address newOwner) onlyOwner public {
    require(newOwner != address(0));
    OwnershipTransferred(owner, newOwner);
    owner = newOwner;
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

 
contract Administrable is Pausable {

     
    mapping(address => uint8) public trustedCurrencyContracts;

     
    event NewTrustedContract(address newContract);
    event RemoveTrustedContract(address oldContract);

     
    function adminAddTrustedCurrencyContract(address _newContractAddress)
        external
        onlyOwner
    {
        trustedCurrencyContracts[_newContractAddress] = 1;  
        NewTrustedContract(_newContractAddress);
    }

     
    function adminRemoveTrustedCurrencyContract(address _oldTrustedContractAddress)
        external
        onlyOwner
    {
        require(trustedCurrencyContracts[_oldTrustedContractAddress] != 0);
        trustedCurrencyContracts[_oldTrustedContractAddress] = 0;
        RemoveTrustedContract(_oldTrustedContractAddress);
    }

     
    function getStatusContract(address _contractAddress)
        view
        external
        returns(uint8) 
    {
        return trustedCurrencyContracts[_contractAddress];
    }

     
    function isTrustedContract(address _contractAddress)
        public
        view
        returns(bool)
    {
        return trustedCurrencyContracts[_contractAddress] == 1;
    }
}


 
contract ERC20Basic {
  uint256 public totalSupply;
  function balanceOf(address who) public constant returns (uint256);
  function transfer(address to, uint256 value) public returns (bool);
  event Transfer(address indexed from, address indexed to, uint256 value);
}


 
contract ERC20 is ERC20Basic {
  function allowance(address owner, address spender) public constant returns (uint256);
  function transferFrom(address from, address to, uint256 value) public returns (bool);
  function approve(address spender, uint256 value) public returns (bool);
  event Approval(address indexed owner, address indexed spender, uint256 value);
}



 
contract RequestCore is Administrable {
    using SafeMath for uint256;
    using SafeMathUint96 for uint96;
    using SafeMathInt for int256;
    using SafeMathUint8 for uint8;

    enum State { Created, Accepted, Canceled }

    struct Request {
         
        address payer;

         
        address currencyContract;

         
        State state;

         
        Payee payee;
    }

     
     
    struct Payee {
         
        address addr;

         
         
        int256 expectedAmount;

         
        int256 balance;
    }

     
     
     
    uint96 public numRequests; 
    
     
     
     
    mapping(bytes32 => Request) requests;

     
     
    mapping(bytes32 => Payee[256]) public subPayees;

     
    event Created(bytes32 indexed requestId, address indexed payee, address indexed payer, address creator, string data);
    event Accepted(bytes32 indexed requestId);
    event Canceled(bytes32 indexed requestId);

     
    event NewSubPayee(bytes32 indexed requestId, address indexed payee);  
    event UpdateExpectedAmount(bytes32 indexed requestId, uint8 payeeIndex, int256 deltaAmount);
    event UpdateBalance(bytes32 indexed requestId, uint8 payeeIndex, int256 deltaAmount);

     
    function createRequest(
        address     _creator,
        address[]   _payees,
        int256[]    _expectedAmounts,
        address     _payer,
        string      _data)
        external
        whenNotPaused 
        returns (bytes32 requestId) 
    {
         
        require(_creator!=0);  
         
        require(isTrustedContract(msg.sender));  

         
        requestId = generateRequestId();

        address mainPayee;
        int256 mainExpectedAmount;
         
        if(_payees.length!=0) {
            mainPayee = _payees[0];
            mainExpectedAmount = _expectedAmounts[0];
        }

         
        requests[requestId] = Request(_payer, msg.sender, State.Created, Payee(mainPayee, mainExpectedAmount, 0));

         
        Created(requestId, mainPayee, _payer, _creator, _data);
        
         
        initSubPayees(requestId, _payees, _expectedAmounts);

        return requestId;
    }

      
    function createRequestFromBytes(bytes _data) 
        external
        whenNotPaused 
        returns (bytes32 requestId) 
    {
         
        require(isTrustedContract(msg.sender));  

         
        address creator = extractAddress(_data, 0);

        address payer = extractAddress(_data, 20);

         
        require(creator!=0);
        
         
        uint8 payeesCount = uint8(_data[40]);

         
         
        uint256 offsetDataSize = uint256(payeesCount).mul(52).add(41);

         
        uint8 dataSize = uint8(_data[offsetDataSize]);
        string memory dataStr = extractString(_data, dataSize, offsetDataSize.add(1));

        address mainPayee;
        int256 mainExpectedAmount;
         
        if(payeesCount!=0) {
            mainPayee = extractAddress(_data, 41);
            mainExpectedAmount = int256(extractBytes32(_data, 61));
        }

         
        requestId = generateRequestId();

         
        requests[requestId] = Request(payer, msg.sender, State.Created, Payee(mainPayee, mainExpectedAmount, 0));

         
        Created(requestId, mainPayee, payer, creator, dataStr);

         
        for(uint8 i = 1; i < payeesCount; i = i.add(1)) {
            address subPayeeAddress = extractAddress(_data, uint256(i).mul(52).add(41));

             
            require(subPayeeAddress != 0);

            subPayees[requestId][i-1] =  Payee(subPayeeAddress, int256(extractBytes32(_data, uint256(i).mul(52).add(61))), 0);
            NewSubPayee(requestId, subPayeeAddress);
        }

        return requestId;
    }

      
    function accept(bytes32 _requestId) 
        external
    {
        Request storage r = requests[_requestId];
        require(r.currencyContract==msg.sender); 
        r.state = State.Accepted;
        Accepted(_requestId);
    }

      
    function cancel(bytes32 _requestId)
        external
    {
        Request storage r = requests[_requestId];
        require(r.currencyContract==msg.sender);
        r.state = State.Canceled;
        Canceled(_requestId);
    }   

      
    function updateBalance(bytes32 _requestId, uint8 _payeeIndex, int256 _deltaAmount)
        external
    {   
        Request storage r = requests[_requestId];
        require(r.currencyContract==msg.sender);

        if( _payeeIndex == 0 ) {
             
            r.payee.balance = r.payee.balance.add(_deltaAmount);
        } else {
             
            Payee storage sp = subPayees[_requestId][_payeeIndex-1];
            sp.balance = sp.balance.add(_deltaAmount);
        }
        UpdateBalance(_requestId, _payeeIndex, _deltaAmount);
    }

      
    function updateExpectedAmount(bytes32 _requestId, uint8 _payeeIndex, int256 _deltaAmount)
        external
    {   
        Request storage r = requests[_requestId];
        require(r.currencyContract==msg.sender); 

        if( _payeeIndex == 0 ) {
             
            r.payee.expectedAmount = r.payee.expectedAmount.add(_deltaAmount);    
        } else {
             
            Payee storage sp = subPayees[_requestId][_payeeIndex-1];
            sp.expectedAmount = sp.expectedAmount.add(_deltaAmount);
        }
        UpdateExpectedAmount(_requestId, _payeeIndex, _deltaAmount);
    }

      
    function initSubPayees(bytes32 _requestId, address[] _payees, int256[] _expectedAmounts)
        internal
    {
        require(_payees.length == _expectedAmounts.length);
     
        for (uint8 i = 1; i < _payees.length; i = i.add(1))
        {
             
            require(_payees[i] != 0);
            subPayees[_requestId][i-1] = Payee(_payees[i], _expectedAmounts[i], 0);
            NewSubPayee(_requestId, _payees[i]);
        }
    }


     
      
    function getPayeeAddress(bytes32 _requestId, uint8 _payeeIndex)
        public
        constant
        returns(address)
    {
        if(_payeeIndex == 0) {
            return requests[_requestId].payee.addr;
        } else {
            return subPayees[_requestId][_payeeIndex-1].addr;
        }
    }

      
    function getPayer(bytes32 _requestId)
        public
        constant
        returns(address)
    {
        return requests[_requestId].payer;
    }

          
    function getPayeeExpectedAmount(bytes32 _requestId, uint8 _payeeIndex)
        public
        constant
        returns(int256)
    {
        if(_payeeIndex == 0) {
            return requests[_requestId].payee.expectedAmount;
        } else {
            return subPayees[_requestId][_payeeIndex-1].expectedAmount;
        }
    }

          
    function getSubPayeesCount(bytes32 _requestId)
        public
        constant
        returns(uint8)
    {
        for (uint8 i = 0; subPayees[_requestId][i].addr != address(0); i = i.add(1)) {
             
        }
        return i;
    }

     
    function getCurrencyContract(bytes32 _requestId)
        public
        constant
        returns(address)
    {
        return requests[_requestId].currencyContract;
    }

          
    function getPayeeBalance(bytes32 _requestId, uint8 _payeeIndex)
        public
        constant
        returns(int256)
    {
        if(_payeeIndex == 0) {
            return requests[_requestId].payee.balance;    
        } else {
            return subPayees[_requestId][_payeeIndex-1].balance;
        }
    }

          
    function getBalance(bytes32 _requestId)
        public
        constant
        returns(int256)
    {
        int256 balance = requests[_requestId].payee.balance;

        for (uint8 i = 0; subPayees[_requestId][i].addr != address(0); i = i.add(1))
        {
            balance = balance.add(subPayees[_requestId][i].balance);
        }

        return balance;
    }


          
    function areAllBalanceNull(bytes32 _requestId)
        public
        constant
        returns(bool isNull)
    {
        isNull = requests[_requestId].payee.balance == 0;

        for (uint8 i = 0; isNull && subPayees[_requestId][i].addr != address(0); i = i.add(1))
        {
            isNull = subPayees[_requestId][i].balance == 0;
        }

        return isNull;
    }

          
    function getExpectedAmount(bytes32 _requestId)
        public
        constant
        returns(int256)
    {
        int256 expectedAmount = requests[_requestId].payee.expectedAmount;

        for (uint8 i = 0; subPayees[_requestId][i].addr != address(0); i = i.add(1))
        {
            expectedAmount = expectedAmount.add(subPayees[_requestId][i].expectedAmount);
        }

        return expectedAmount;
    }

      
    function getState(bytes32 _requestId)
        public
        constant
        returns(State)
    {
        return requests[_requestId].state;
    }

     
    function getPayeeIndex(bytes32 _requestId, address _address)
        public
        constant
        returns(int16)
    {
         
        if(requests[_requestId].payee.addr == _address) return 0;

        for (uint8 i = 0; subPayees[_requestId][i].addr != address(0); i = i.add(1))
        {
            if(subPayees[_requestId][i].addr == _address) {
                 
                return i+1;
            }
        }
        return -1;
    }

      
    function getRequest(bytes32 _requestId) 
        external
        constant
        returns(address payer, address currencyContract, State state, address payeeAddr, int256 payeeExpectedAmount, int256 payeeBalance)
    {
        Request storage r = requests[_requestId];
        return ( r.payer, 
                 r.currencyContract, 
                 r.state, 
                 r.payee.addr, 
                 r.payee.expectedAmount, 
                 r.payee.balance );
    }

      
    function extractString(bytes data, uint8 size, uint _offset) 
        internal 
        pure 
        returns (string) 
    {
        bytes memory bytesString = new bytes(size);
        for (uint j = 0; j < size; j++) {
            bytesString[j] = data[_offset+j];
        }
        return string(bytesString);
    }

      
    function generateRequestId()
        internal
        returns (bytes32)
    {
         
        numRequests = numRequests.add(1);
         
        return bytes32((uint256(this) << 96).add(numRequests));
    }

     
    function extractAddress(bytes _data, uint offset)
        internal
        pure
        returns (address m)
    {
        require(offset >=0 && offset + 20 <= _data.length);
        assembly {
            m := and( mload(add(_data, add(20, offset))), 
                      0xFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFF)
        }
    }

     
    function extractBytes32(bytes _data, uint offset)
        public
        pure
        returns (bytes32 bs)
    {
        require(offset >=0 && offset + 32 <= _data.length);
        assembly {
            bs := mload(add(_data, add(32, offset)))
        }
    }

     
    function emergencyERC20Drain(ERC20 token, uint amount )
        public
        onlyOwner 
    {
        token.transfer(owner, amount);
    }
}

 
contract RequestCollectInterface is Pausable {
  using SafeMath for uint256;

    uint256 public rateFeesNumerator;
    uint256 public rateFeesDenominator;
    uint256 public maxFees;

   
  address public requestBurnerContract;

     
    event UpdateRateFees(uint256 rateFeesNumerator, uint256 rateFeesDenominator);
    event UpdateMaxFees(uint256 maxFees);

     
  function RequestCollectInterface(address _requestBurnerContract) 
    public
  {
    requestBurnerContract = _requestBurnerContract;
  }

     
  function collectForREQBurning(uint256 _amount)
    internal
    returns(bool)
  {
    return requestBurnerContract.send(_amount);
  }

     
  function collectEstimation(int256 _expectedAmount)
    public
    view
    returns(uint256)
  {
    if(_expectedAmount<0) return 0;

    uint256 computedCollect = uint256(_expectedAmount).mul(rateFeesNumerator);

    if(rateFeesDenominator != 0) {
      computedCollect = computedCollect.div(rateFeesDenominator);
    }

    return computedCollect < maxFees ? computedCollect : maxFees;
  }

     
  function setRateFees(uint256 _rateFeesNumerator, uint256 _rateFeesDenominator)
    external
    onlyOwner
  {
    rateFeesNumerator = _rateFeesNumerator;
        rateFeesDenominator = _rateFeesDenominator;
    UpdateRateFees(rateFeesNumerator, rateFeesDenominator);
  }

     
  function setMaxCollectable(uint256 _newMaxFees) 
    external
    onlyOwner
  {
    maxFees = _newMaxFees;
    UpdateMaxFees(maxFees);
  }

     
  function setRequestBurnerContract(address _requestBurnerContract) 
    external
    onlyOwner
  {
    requestBurnerContract=_requestBurnerContract;
  }

}


 
contract RequestCurrencyContractInterface is RequestCollectInterface {
    using SafeMath for uint256;
    using SafeMathInt for int256;
    using SafeMathUint8 for uint8;

     
    RequestCore public requestCore;

     
    function RequestCurrencyContractInterface(address _requestCoreAddress, address _addressBurner) 
        RequestCollectInterface(_addressBurner)
        public
    {
        requestCore=RequestCore(_requestCoreAddress);
    }

    function createCoreRequestInternal(
        address     _payer,
        address[]   _payeesIdAddress,
        int256[]    _expectedAmounts,
        string      _data)
        internal
        whenNotPaused
        returns(bytes32 requestId, int256 totalExpectedAmounts)
    {
        totalExpectedAmounts = 0;
        for (uint8 i = 0; i < _expectedAmounts.length; i = i.add(1))
        {
             
            require(_expectedAmounts[i]>=0);
             
            totalExpectedAmounts = totalExpectedAmounts.add(_expectedAmounts[i]);
        }

         
        requestId= requestCore.createRequest(msg.sender, _payeesIdAddress, _expectedAmounts, _payer, _data);
    }

    function acceptAction(bytes32 _requestId)
        public
        whenNotPaused
        onlyRequestPayer(_requestId)
    {
         
        require(requestCore.getState(_requestId)==RequestCore.State.Created);

         
        requestCore.accept(_requestId);
    }

    function cancelAction(bytes32 _requestId)
        public
        whenNotPaused
    {
         
         
        require((requestCore.getPayer(_requestId)==msg.sender && requestCore.getState(_requestId)==RequestCore.State.Created)
                || (requestCore.getPayeeAddress(_requestId,0)==msg.sender && requestCore.getState(_requestId)!=RequestCore.State.Canceled));

         
        require(requestCore.areAllBalanceNull(_requestId));

         
        requestCore.cancel(_requestId);
    }

    function additionalAction(bytes32 _requestId, uint256[] _additionalAmounts)
        public
        whenNotPaused
        onlyRequestPayer(_requestId)
    {

         
        require(requestCore.getState(_requestId)!=RequestCore.State.Canceled);

         
        require(_additionalAmounts.length <= requestCore.getSubPayeesCount(_requestId).add(1));

        for(uint8 i = 0; i < _additionalAmounts.length; i = i.add(1)) {
             
            if(_additionalAmounts[i] != 0) {
                 
                requestCore.updateExpectedAmount(_requestId, i, _additionalAmounts[i].toInt256Safe());
            }
        }
    }

    function subtractAction(bytes32 _requestId, uint256[] _subtractAmounts)
        public
        whenNotPaused
        onlyRequestPayee(_requestId)
    {
         
        require(requestCore.getState(_requestId)!=RequestCore.State.Canceled);

         
        require(_subtractAmounts.length <= requestCore.getSubPayeesCount(_requestId).add(1));

        for(uint8 i = 0; i < _subtractAmounts.length; i = i.add(1)) {
             
            if(_subtractAmounts[i] != 0) {
                 
                require(requestCore.getPayeeExpectedAmount(_requestId,i) >= _subtractAmounts[i].toInt256Safe());
                 
                requestCore.updateExpectedAmount(_requestId, i, -_subtractAmounts[i].toInt256Safe());
            }
        }
    }
     

      
    modifier onlyRequestPayee(bytes32 _requestId)
    {
        require(requestCore.getPayeeAddress(_requestId, 0)==msg.sender);
        _;
    }

      
    modifier onlyRequestPayer(bytes32 _requestId)
    {
        require(requestCore.getPayer(_requestId)==msg.sender);
        _;
    }
}

 
contract RequestBitcoinNodesValidation is RequestCurrencyContractInterface {
    using SafeMath for uint256;
    using SafeMathInt for int256;
    using SafeMathUint8 for uint8;

     
     
    mapping(bytes32 => string[256]) public payeesPaymentAddress;
     
    mapping(bytes32 => string[256]) public payerRefundAddress;

     
    function RequestBitcoinNodesValidation(address _requestCoreAddress, address _requestBurnerAddress) 
        RequestCurrencyContractInterface(_requestCoreAddress, _requestBurnerAddress)
        public
    {
         
    }

     
    function createRequestAsPayeeAction(
        address[]    _payeesIdAddress,
        bytes        _payeesPaymentAddress,
        int256[]     _expectedAmounts,
        address      _payer,
        bytes        _payerRefundAddress,
        string       _data)
        external
        payable
        whenNotPaused
        returns(bytes32 requestId)
    {
        require(msg.sender == _payeesIdAddress[0] && msg.sender != _payer && _payer != 0);

        int256 totalExpectedAmounts;
        (requestId, totalExpectedAmounts) = createCoreRequestInternal(_payer, _payeesIdAddress, _expectedAmounts, _data);
        
         
        uint256 fees = collectEstimation(totalExpectedAmounts);
        require(fees == msg.value && collectForREQBurning(fees));
    
        extractAndStoreBitcoinAddresses(requestId, _payeesIdAddress.length, _payeesPaymentAddress, _payerRefundAddress);
        
        return requestId;
    }

     
    function extractAndStoreBitcoinAddresses(
        bytes32     _requestId,
        uint256     _payeesCount,
        bytes       _payeesPaymentAddress,
        bytes       _payerRefundAddress) 
        internal
    {
         
        uint256 cursor = 0;
        uint8 sizeCurrentBitcoinAddress;
        uint8 j;
        for (j = 0; j < _payeesCount; j = j.add(1)) {
             
            sizeCurrentBitcoinAddress = uint8(_payeesPaymentAddress[cursor]);

             
            payeesPaymentAddress[_requestId][j] = extractString(_payeesPaymentAddress, sizeCurrentBitcoinAddress, ++cursor);

             
            cursor += sizeCurrentBitcoinAddress;
        }

         
        cursor = 0;
        for (j = 0; j < _payeesCount; j = j.add(1)) {
             
            sizeCurrentBitcoinAddress = uint8(_payerRefundAddress[cursor]);

             
            payerRefundAddress[_requestId][j] = extractString(_payerRefundAddress, sizeCurrentBitcoinAddress, ++cursor);

             
            cursor += sizeCurrentBitcoinAddress;
        }
    }

     
    function broadcastSignedRequestAsPayerAction(
        bytes         _requestData,  
        bytes         _payeesPaymentAddress,
        bytes         _payerRefundAddress,
        uint256[]     _additionals,
        uint256       _expirationDate,
        bytes         _signature)
        external
        payable
        whenNotPaused
        returns(bytes32 requestId)
    {
         
        require(_expirationDate >= block.timestamp);

         
        require(checkRequestSignature(_requestData, _payeesPaymentAddress, _expirationDate, _signature));

        return createAcceptAndAdditionalsFromBytes(_requestData, _payeesPaymentAddress, _payerRefundAddress, _additionals);
    }

     
    function createAcceptAndAdditionalsFromBytes(
        bytes         _requestData,
        bytes         _payeesPaymentAddress,
        bytes         _payerRefundAddress,
        uint256[]     _additionals)
        internal
        returns(bytes32 requestId)
    {
         
        address mainPayee = extractAddress(_requestData, 41);
        require(msg.sender != mainPayee && mainPayee != 0);
         
        require(extractAddress(_requestData, 0) == mainPayee);

         
        uint8 payeesCount = uint8(_requestData[40]);
        int256 totalExpectedAmounts = 0;
        for(uint8 i = 0; i < payeesCount; i++) {
             
            int256 expectedAmountTemp = int256(extractBytes32(_requestData, uint256(i).mul(52).add(61)));
             
            totalExpectedAmounts = totalExpectedAmounts.add(expectedAmountTemp);
             
            require(expectedAmountTemp>0);
        }

         
        uint256 fees = collectEstimation(totalExpectedAmounts);
         
        require(fees == msg.value && collectForREQBurning(fees));

         
        updateBytes20inBytes(_requestData, 20, bytes20(msg.sender));
         
        requestId = requestCore.createRequestFromBytes(_requestData);
        
         
        extractAndStoreBitcoinAddresses(requestId, payeesCount, _payeesPaymentAddress, _payerRefundAddress);

         
        acceptAndAdditionals(requestId, _additionals);

        return requestId;
    }

         
    function acceptAndAdditionals(
        bytes32     _requestId,
        uint256[]   _additionals)
        internal
    {
        acceptAction(_requestId);
        
        additionalAction(_requestId, _additionals);
    }
     

         
    function checkRequestSignature(
        bytes         _requestData,
        bytes         _payeesPaymentAddress,
        uint256       _expirationDate,
        bytes         _signature)
        public
        view
        returns (bool)
    {
        bytes32 hash = getRequestHash(_requestData, _payeesPaymentAddress, _expirationDate);

         
        uint8 v = uint8(_signature[64]);
        v = v < 27 ? v.add(27) : v;
        bytes32 r = extractBytes32(_signature, 0);
        bytes32 s = extractBytes32(_signature, 32);

         
        return isValidSignature(extractAddress(_requestData, 0), hash, v, r, s);
    }

     
    function getRequestHash(
        bytes       _requestData,
        bytes       _payeesPaymentAddress,
        uint256     _expirationDate)
        internal
        view
        returns(bytes32)
    {
        return keccak256(this,_requestData, _payeesPaymentAddress, _expirationDate);
    }

     
    function isValidSignature(
        address     signer,
        bytes32     hash,
        uint8       v,
        bytes32     r,
        bytes32     s)
        public
        pure
        returns (bool)
    {
        return signer == ecrecover(
            keccak256("\x19Ethereum Signed Message:\n32", hash),
            v,
            r,
            s
        );
    }

     
    function extractAddress(bytes _data, uint offset)
        internal
        pure
        returns (address m) 
    {
        require(offset >=0 && offset + 20 <= _data.length);
        assembly {
            m := and( mload(add(_data, add(20, offset))), 
                      0xFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFF)
        }
    }

     
    function extractBytes32(bytes _data, uint offset)
        public
        pure
        returns (bytes32 bs)
    {
        require(offset >=0 && offset + 32 <= _data.length);
        assembly {
            bs := mload(add(_data, add(32, offset)))
        }
    }

     
    function updateBytes20inBytes(bytes data, uint offset, bytes20 b)
        internal
        pure
    {
        require(offset >=0 && offset + 20 <= data.length);
        assembly {
            let m := mload(add(data, add(20, offset)))
            m := and(m, 0xFFFFFFFFFFFFFFFFFFFFFFFF0000000000000000000000000000000000000000)
            m := or(m, div(b, 0x1000000000000000000000000))
            mstore(add(data, add(20, offset)), m)
        }
    }

      
    function extractString(bytes data, uint8 size, uint _offset) 
        internal 
        pure 
        returns (string) 
    {
        bytes memory bytesString = new bytes(size);
        for (uint j = 0; j < size; j++) {
            bytesString[j] = data[_offset+j];
        }
        return string(bytesString);
    }
}