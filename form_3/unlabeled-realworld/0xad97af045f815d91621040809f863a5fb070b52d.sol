 

pragma solidity ^0.4.23;
     
    contract ERC20Basic {
     function totalSupply() public view returns (uint256);
     function balanceOf(address who) public view returns (uint256);
     function transfer(address to, uint256 value) public returns (bool);
     event Transfer(address indexed from, address indexed to, uint256 value);
   }
     
    contract Ownable {
     address public owner;
     event OwnershipTransferred(address indexed previousOwner, address indexed newOwner);
      
      constructor() public {
       owner = msg.sender;
     }
      
      modifier onlyOwner() {
       require(msg.sender == owner);
       _;
     }
      
      function transferOwnership(address newOwner) public onlyOwner {
       require(newOwner != address(0));
       emit OwnershipTransferred(owner, newOwner);
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
       emit Pause();
     }

      
      function unpause() onlyOwner whenPaused public {
       paused = false;
       emit Unpause();
     }
   }

     
    contract Whitelist is Pausable {
     mapping(address => bool) public whitelist;

     event WhitelistedAddressAdded(address addr);
     event WhitelistedAddressRemoved(address addr);
      
      modifier onlyWhitelisted() {
       require(whitelist[msg.sender]);
       _;
     }
      
      function addAddressToWhitelist(address addr) onlyOwner public returns(bool success) {
       if (!whitelist[addr]) {
         whitelist[addr] = true;
         emit WhitelistedAddressAdded(addr);
         success = true;
       }
     }
      
      function addAddressesToWhitelist(address[] addrs) onlyOwner public returns(bool success) {
       for (uint256 i = 0; i < addrs.length; i++) {
         if (addAddressToWhitelist(addrs[i])) {
           success = true;
         }
       }
     }
      
      function removeAddressFromWhitelist(address addr) onlyOwner public returns(bool success) {
       if (whitelist[addr]) {
         whitelist[addr] = false;
         emit WhitelistedAddressRemoved(addr);
         success = true;
       }
     }
      
      function removeAddressesFromWhitelist(address[] addrs) onlyOwner public returns(bool success) {
       for (uint256 i = 0; i < addrs.length; i++) {
         if (removeAddressFromWhitelist(addrs[i])) {
           success = true;
         }
       }
     }
   }
     
    contract ERC20 is ERC20Basic {
     function allowance(address owner, address spender) public view returns (uint256);
     function transferFrom(address from, address to, uint256 value) public returns (bool);
     function approve(address spender, uint256 value) public returns (bool);
     event Approval(address indexed owner, address indexed spender, uint256 value);
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
     
    contract Crowdsale is Whitelist{
     using SafeMath for uint256;
      
     MiniMeToken public token;
      
     address public wallet;
      
     uint256 public rate = 6120;
      
     uint256 public tokensSold;
     
     uint256 startTime;



      
      event TokenPurchase(address indexed purchaser, address indexed beneficiary, uint256 value, uint256 amount);

      event buyx(address buyer, address contractAddr, uint256 amount);

      constructor(address _wallet, MiniMeToken _token, uint256 starttime) public{

       require(_wallet != address(0));
       require(_token != address(0));

       wallet = _wallet;
       token = _token;
       startTime = starttime;
     }
     function setCrowdsale(address _wallet, MiniMeToken _token, uint256 starttime) public{


       require(_wallet != address(0));
       require(_token != address(0));

       wallet = _wallet;
       token = _token;
       startTime = starttime;
     }



      
      
      
      
      function () external whenNotPaused payable {
        emit buyx(msg.sender, this, _getTokenAmount(msg.value));
        buyTokens(msg.sender);
      }
      
     function buyTokens(address _beneficiary) public whenNotPaused payable {
      
       if ((tokensSold > 20884500000000000000000000 ) && (tokensSold <= 30791250000000000000000000)) {
         rate = 5967;
       }
       else if ((tokensSold > 30791250000000000000000000) && (tokensSold <= 39270000000000000000000000)) {
        rate = 5865;
       }
       else if ((tokensSold > 39270000000000000000000000) && (tokensSold <= 46856250000000000000000000)) {
        rate = 5610;
       }
       else if ((tokensSold > 46856250000000000000000000) && (tokensSold <= 35700000000000000000000000)) {
        rate = 5355;
       }
       else if (tokensSold > 35700000000000000000000000) {
        rate = 5100;
       }


      uint256 weiAmount = msg.value;
      uint256 tokens = _getTokenAmount(weiAmount);
      tokensSold = tokensSold.add(tokens);
      _processPurchase(_beneficiary, tokens);
      emit TokenPurchase(msg.sender, _beneficiary, weiAmount, tokens);
      _updatePurchasingState(_beneficiary, weiAmount);
      _forwardFunds();
      _postValidatePurchase(_beneficiary, weiAmount);
    }

     
     
     



      
      function _preValidatePurchase(address _beneficiary, uint256 _weiAmount) internal {
       require(_beneficiary != address(0));
       require(_weiAmount != 0);
     }
      
      function _postValidatePurchase(address _beneficiary, uint256 _weiAmount) internal {
        
     }
      
      function _deliverTokens(address _beneficiary, uint256 _tokenAmount) internal {
       token.transfer(_beneficiary, _tokenAmount);
     }
      
      function _processPurchase(address _beneficiary, uint256 _tokenAmount) internal {
       _deliverTokens(_beneficiary, _tokenAmount);
     }
      
      function _updatePurchasingState(address _beneficiary, uint256 _weiAmount) internal {
        
     }
      
      function _getTokenAmount(uint256 _weiAmount) internal  returns (uint256) {

       return _weiAmount.mul(rate);
     }

      
      function _forwardFunds() internal {
       wallet.transfer(msg.value);
     }

   }



   contract EmaCrowdSale is Crowdsale {
    uint256 public hardcap;
    uint256 public starttime;
    Crowdsale public csale;
    using SafeMath for uint256; 
    constructor(address wallet, MiniMeToken token, uint256 startTime, uint256 cap) Crowdsale(wallet, token, starttime) public onlyOwner
    {

      hardcap = cap;
      starttime = startTime;
      setCrowdsale(wallet, token, startTime);
    }

function tranferPresaleTokens(address investor, uint256 ammount)public onlyOwner{
    tokensSold = tokensSold.add(ammount); 
    token.transferFrom(this, investor, ammount); 
}

    function setTokenTransferState(bool state) public onlyOwner {
     token.changeController(this);
     token.enableTransfers(state);
   }

   function claim(address claimToken) public onlyOwner {
     token.changeController(this);
     token.claimTokens(claimToken);
   }

   function () external payable onlyWhitelisted whenNotPaused{

    emit buyx(msg.sender, this, _getTokenAmount(msg.value));

    buyTokens(msg.sender);
  }


}






contract Controlled is Pausable {
  
  
 modifier onlyController { require(msg.sender == controller); _; }
 modifier onlyControllerorOwner { require((msg.sender == controller) || (msg.sender == owner)); _; }
 address public controller;
 constructor() public { controller = msg.sender;}
  
  
 function changeController(address _newController) public onlyControllerorOwner {
   controller = _newController;
 }
}
 
contract TokenController {
  
  
  
 function proxyPayment(address _owner) public payable returns(bool);
  
  
  
  
  
  
 function onTransfer(address _from, address _to, uint _amount) public returns(bool);
  
  
  
  
  
  
 function onApprove(address _owner, address _spender, uint _amount) public
 returns(bool);
}
     
        
        
        
        
        
        
        
       contract ApproveAndCallFallBack {
         function receiveApproval(address from, uint256 _amount, address _token, bytes _data) public;
       }
        
        
        
       contract MiniMeToken is Controlled
       {
         using SafeMath for uint256;
         string public name;                 
         uint8 public decimals;              
         string public symbol;               
         string public version = 'V 1.0';  
          
          
          
         struct  Checkpoint {
            
           uint128 fromBlock;
            
           uint128 value;
         }
          
          
         MiniMeToken public parentToken;
          
          
         uint public parentSnapShotBlock;
          
         uint public creationBlock;
          
          
          
         mapping (address => Checkpoint[]) balances;
          
         mapping (address => mapping (address => uint256)) allowed;
          
         Checkpoint[] totalSupplyHistory;
          
         bool public transfersEnabled;
          
         MiniMeTokenFactory public tokenFactory;
          
          
          
          
          
          
          
          
          
          
          
          
          
          
          
          
         constructor(
           address _tokenFactory,
           address _parentToken,
           uint _parentSnapShotBlock,
           string _tokenName,
           uint8 _decimalUnits,
           string _tokenSymbol,
           bool _transfersEnabled
           ) public {
           tokenFactory = MiniMeTokenFactory(_tokenFactory);
           name = _tokenName;                                  
           decimals = _decimalUnits;                           
           symbol = _tokenSymbol;                              
           parentToken = MiniMeToken(_parentToken);
           parentSnapShotBlock = _parentSnapShotBlock;
           transfersEnabled = _transfersEnabled;
           creationBlock = block.number;
         }
          
          
          
          
          
          
          
         function transfer(address _to, uint256 _amount) public returns (bool success)  {
           require(transfersEnabled);
           doTransfer(msg.sender, _to, _amount);
           return true;
         }
          
          
          
          
          
          
         function transferFrom(address _from, address _to, uint256 _amount
           ) public  returns (bool success) {
            
            
            
            
           if (msg.sender != controller) {
             require(transfersEnabled);
              
             require(allowed[_from][msg.sender] >= _amount);
             allowed[_from][msg.sender] = allowed[_from][msg.sender].sub(_amount);
           }
           doTransfer(_from, _to, _amount);
           return true;
         }

          
          
          
          
          
          
         function doTransfer(address _from, address _to, uint _amount
           ) internal {
          if (_amount == 0) {
            emit Transfer(_from, _to, _amount);     
            return;
          }

           
          require((_to != 0) && (_to != address(this)));
           
           
          uint256 previousBalanceFrom = balanceOfAt(_from, block.number);
          require(previousBalanceFrom >= _amount);
           
          updateValueAtNow(balances[_from], previousBalanceFrom - _amount);
           
           
          uint256 previousBalanceTo = balanceOfAt(_to, block.number);
          require(previousBalanceTo.add(_amount) >= previousBalanceTo);  
          updateValueAtNow(balances[_to], previousBalanceTo.add(_amount));
           
          emit Transfer(_from, _to, _amount);
        }
         
         
        function balanceOf(address _owner) public constant returns (uint256 balance) {
         return balanceOfAt(_owner, block.number);
       }
        
        
        
        
        
        
       function approve(address _spender, uint256 _amount) public returns (bool success) {
        require(transfersEnabled);
         
         
         
         
        require((_amount == 0) || (allowed[msg.sender][_spender] == 0));
         
        if (isContract(controller)) {
         require(TokenController(controller).onApprove(msg.sender, _spender, _amount));
       }
       allowed[msg.sender][_spender] = _amount;
       emit Approval(msg.sender, _spender, _amount);
       return true;
     }
      
      
      
      
      
     function allowance(address _owner, address _spender
       ) public constant returns (uint256 remaining) {
       return allowed[_owner][_spender];
     }
      
      
      
      
      
      
      
     function approveAndCall(address _spender, uint256 _amount, bytes _extraData
       ) public returns (bool success) {
       require(approve(_spender, _amount));
       ApproveAndCallFallBack(_spender).receiveApproval(
         msg.sender,
         _amount,
         this,
         _extraData
         );
       return true;
     }
      
      
     function totalSupply() public constant returns (uint) {
       return totalSupplyAt(block.number);
     }
      
      
      
      
      
      
      
     function balanceOfAt(address _owner, uint _blockNumber) public constant
     returns (uint) {
        
        
        
        
        
       if ((balances[_owner].length == 0)
         || (balances[_owner][0].fromBlock > _blockNumber)) {
         if (address(parentToken) != 0) {
           return parentToken.balanceOfAt(_owner, min(_blockNumber, parentSnapShotBlock));
           } else {
              
             return 0;
           }
            
           } else {
             return getValueAt(balances[_owner], _blockNumber);
           }
         }
          
          
          
         function totalSupplyAt(uint _blockNumber) public constant returns(uint) {
            
            
            
            
            
           if ((totalSupplyHistory.length == 0)
             || (totalSupplyHistory[0].fromBlock > _blockNumber)) {
             if (address(parentToken) != 0) {
               return parentToken.totalSupplyAt(min(_blockNumber, parentSnapShotBlock));
               } else {
                 return 0;
               }
                
               } else {
                 return getValueAt(totalSupplyHistory, _blockNumber);
               }
             }
             
              
              
              
              
              
              
              
             function generateTokens(address _owner, uint _amount
               ) public onlyControllerorOwner whenNotPaused  returns (bool) {
               uint curTotalSupply = totalSupply();
               require(curTotalSupply.add(_amount) >= curTotalSupply);  
               uint previousBalanceTo = balanceOf(_owner);
               require(previousBalanceTo.add(_amount) >= previousBalanceTo);  
               updateValueAtNow(totalSupplyHistory, curTotalSupply.add(_amount));
               updateValueAtNow(balances[_owner], previousBalanceTo.add(_amount));
               emit Transfer(0, _owner, _amount);
               return true;
             }
              
              
              
              
             function destroyTokens(address _owner, uint _amount
               ) onlyControllerorOwner public returns (bool) {
               uint curTotalSupply = totalSupply();
               require(curTotalSupply >= _amount);
               uint previousBalanceFrom = balanceOf(_owner);
               require(previousBalanceFrom >= _amount);
               updateValueAtNow(totalSupplyHistory, curTotalSupply.sub(_amount));
               updateValueAtNow(balances[_owner], previousBalanceFrom.sub(_amount));
               emit Transfer(_owner, 0, _amount);
               return true;
             }
              
              
              
              
              
             function enableTransfers(bool _transfersEnabled) public onlyControllerorOwner {
               transfersEnabled = _transfersEnabled;
             }
              
              
              
              
              
              
              
             function getValueAt(Checkpoint[] storage checkpoints, uint _block
               ) constant internal returns (uint) {
               if (checkpoints.length == 0) return 0;
                
               if (_block >= checkpoints[checkpoints.length.sub(1)].fromBlock)
               return checkpoints[checkpoints.length.sub(1)].value;
               if (_block < checkpoints[0].fromBlock) return 0;
                
               uint min = 0;
               uint max = checkpoints.length.sub(1);
               while (max > min) {
                 uint mid = (max.add(min).add(1)).div(2);
                 if (checkpoints[mid].fromBlock<=_block) {
                   min = mid;
                   } else {
                     max = mid.sub(1);
                   }
                 }
                 return checkpoints[min].value;
               }
                
                
                
                
               function updateValueAtNow(Checkpoint[] storage checkpoints, uint _value
                 ) internal  {
                 if ((checkpoints.length == 0)
                   || (checkpoints[checkpoints.length.sub(1)].fromBlock < block.number)) {
                  Checkpoint storage newCheckPoint = checkpoints[ checkpoints.length++ ];
                  newCheckPoint.fromBlock =  uint128(block.number);
                  newCheckPoint.value = uint128(_value);
                  } else {
                    Checkpoint storage oldCheckPoint = checkpoints[checkpoints.length.sub(1)];
                    oldCheckPoint.value = uint128(_value);
                  }
                }
                 
                 
                 
                function isContract(address _addr) constant internal returns(bool) {
                 uint size;
                 if (_addr == 0) return false;
                 assembly {
                   size := extcodesize(_addr)
                 }
                 return size>0;
               }
                
               function min(uint a, uint b) pure internal returns (uint) {
                 return a < b ? a : b;
               }
                
                
                
               function () public payable {
            
           revert();
         }
          
          
          
          
          
          
          
         function claimTokens(address _token) public onlyControllerorOwner {
           if (_token == 0x0) {
             controller.transfer(address(this).balance);
             return;
           }
           MiniMeToken token = MiniMeToken(_token);
           uint balance = token.balanceOf(this);
           token.transfer(controller, balance);
           emit ClaimedTokens(_token, controller, balance);
         }
          
          
          
         event ClaimedTokens(address indexed _token, address indexed _controller, uint _amount);
         event Transfer(address indexed _from, address indexed _to, uint256 _amount);
         event NewCloneToken(address indexed _cloneToken, uint _snapshotBlock);
         event Approval(
           address indexed _owner,
           address indexed _spender,
           uint256 _amount
           );
       }
        
        
        
        
        
        
       contract MiniMeTokenFactory {
          
          
          
          
          
          
          
          
          
          
         function createCloneToken(
           address _parentToken,
           uint _snapshotBlock,
           string _tokenName,
           uint8 _decimalUnits,
           string _tokenSymbol,
           bool _transfersEnabled
           ) public returns (MiniMeToken) {
           MiniMeToken newToken = new MiniMeToken(
             this,
             _parentToken,
             _snapshotBlock,
             _tokenName,
             _decimalUnits,
             _tokenSymbol,
             _transfersEnabled
             );
           newToken.changeController(msg.sender);
           return newToken;
         }
       }

       contract EmaToken is MiniMeToken {
        constructor(address tokenfactory, address parenttoken, uint parentsnapshot, string tokenname, uint8 dec, string tokensymbol, bool transfersenabled)
        MiniMeToken(tokenfactory, parenttoken, parentsnapshot, tokenname, dec, tokensymbol, transfersenabled) public{
        }
      }
      contract Configurator is Ownable {
        EmaToken public token = EmaToken(0xC3EE57Fa8eD253E3F214048879977265967AE745);
        EmaCrowdSale public crowdsale = EmaCrowdSale(0xAd97aF045F815d91621040809F863a5fb070B52d);
        address ownerWallet = 0x3046751e1d843748b4983D7bca58ECF6Ef1e5c77;
        address tokenfactory = 0xB74AA356913316ce49626527AE8543FFf23bB672;
        address fundsWallet = 0x3046751e1d843748b4983D7bca58ECF6Ef1e5c77;
        address incetivesPool = 0x95eac65414a6a650E2c71e3480AeEF0cF76392FA;
        address FoundersAndTeam = 0x88C952c4A8fc156b883318CdA8b4a5279d989391;
        address FuturePartners = 0x5B0333399E0D8F3eF1e5202b4eA4ffDdFD7a0382;
        address Contributors = 0xa02dfB73de485Ebd9d37CbA4583e916F3bA94CeE;
        address BountiesWal = 0xaB662f89A2c6e71BD8c7f754905cAaEC326BcdE7;
        uint256 public crowdSaleStart;


        function deploy() onlyOwner public{
 	    owner = msg.sender; 
	    
	  
	 
	 
	 
		token.generateTokens(crowdsale, 255000000000000000000000000);  
		token.generateTokens(incetivesPool, 115000000000000000000000000);  
		token.generateTokens(FoundersAndTeam, 85000000000000000000000000);  
		token.generateTokens(FuturePartners, 40000000000000000000000000);  
		token.generateTokens(BountiesWal, 5000000000000000000000000);  
		token.changeController(EmaCrowdSale(crowdsale));
			token.transferOwnership(ownerWallet);
			crowdsale.transferOwnership(ownerWallet);
        }
      }