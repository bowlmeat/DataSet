 

 
 
 
 
 


pragma solidity ^0.4.15;


 


 

library SafeMath {
  function mul(uint a, uint b) internal returns (uint) {
    uint c = a * b;
    assert(a == 0 || c / a == b);
    return c;
  }

  function div(uint a, uint b) internal returns (uint) {
     
    uint c = a / b;
     
    return c;
  }

  function sub(uint a, uint b) internal returns (uint) {
    assert(b <= a);
    return a - b;
  }

  function add(uint a, uint b) internal returns (uint) {
    uint c = a + b;
    assert(c >= a);
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

  function percent(uint a, uint b) internal returns (uint) {
    uint c = a * b;
    assert(a == 0 || c / a == b);
    return c / 100;
  }
}


 

  
  

 
 
 
 
 
 
 


 
contract TokenController {
     
     
     
    function proxyPayment(address _owner) payable returns(bool);

     
     
     
     
     
     
    function onTransfer(address _from, address _to, uint _amount) returns(bool);

     
     
     
     
     
     
    function onApprove(address _owner, address _spender, uint _amount)
        returns(bool);
}

contract Controlled {
     
     
    modifier onlyController { require(msg.sender == controller); _; }

    address public controller;

    function Controlled() { controller = msg.sender;}

     
     
    function changeController(address _newController) onlyController {
        controller = _newController;
    }
}

contract ApproveAndCallFallBack {
    function receiveApproval(address from, uint256 _amount, address _token, bytes _data);
}

 
 
 
contract MiniMeToken is Controlled {

    string public name;                 
    uint8 public decimals;              
    string public symbol;               
    string public version = 'MMT_0.1';  


     
     
     
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

 
 
 

     
     
     
     
     
     
     
     
     
     
     
     
     
    function MiniMeToken(
        address _tokenFactory,
        address _parentToken,
        uint _parentSnapShotBlock,
        string _tokenName,
        uint8 _decimalUnits,
        string _tokenSymbol,
        bool _transfersEnabled
    ) {
        tokenFactory = MiniMeTokenFactory(_tokenFactory);
        name = _tokenName;                                  
        decimals = _decimalUnits;                           
        symbol = _tokenSymbol;                              
        parentToken = MiniMeToken(_parentToken);
        parentSnapShotBlock = _parentSnapShotBlock;
        transfersEnabled = _transfersEnabled;
        creationBlock = block.number;
    }


 
 
 

     
     
     
     
    function transfer(address _to, uint256 _amount) returns (bool success) {
        require(transfersEnabled);
        return doTransfer(msg.sender, _to, _amount);
    }

     
     
     
     
     
     
    function transferFrom(address _from, address _to, uint256 _amount
    ) returns (bool success) {

         
         
         
         
        if (msg.sender != controller) {
            require(transfersEnabled);

             
            if (allowed[_from][msg.sender] < _amount) return false;
            allowed[_from][msg.sender] -= _amount;
        }
        return doTransfer(_from, _to, _amount);
    }

     
     
     
     
     
     
    function doTransfer(address _from, address _to, uint _amount
    ) internal returns(bool) {

           if (_amount == 0) {
               return true;
           }

           require(parentSnapShotBlock < block.number);

            
           require((_to != 0) && (_to != address(this)));

            
            
           var previousBalanceFrom = balanceOfAt(_from, block.number);
           if (previousBalanceFrom < _amount) {
               return false;
           }

            
           if (isContract(controller)) {
               require(TokenController(controller).onTransfer(_from, _to, _amount));
           }

            
            
           updateValueAtNow(balances[_from], previousBalanceFrom - _amount);

            
            
           var previousBalanceTo = balanceOfAt(_to, block.number);
           require(previousBalanceTo + _amount >= previousBalanceTo);  
           updateValueAtNow(balances[_to], previousBalanceTo + _amount);

            
           Transfer(_from, _to, _amount);

           return true;
    }

     
     
    function balanceOf(address _owner) constant returns (uint256 balance) {
        return balanceOfAt(_owner, block.number);
    }

     
     
     
     
     
     
    function approve(address _spender, uint256 _amount) returns (bool success) {
        require(transfersEnabled);

         
         
         
         
        require((_amount == 0) || (allowed[msg.sender][_spender] == 0));

         
        if (isContract(controller)) {
            require(TokenController(controller).onApprove(msg.sender, _spender, _amount));
        }

        allowed[msg.sender][_spender] = _amount;
        Approval(msg.sender, _spender, _amount);
        return true;
    }

     
     
     
     
     
    function allowance(address _owner, address _spender
    ) constant returns (uint256 remaining) {
        return allowed[_owner][_spender];
    }

     
     
     
     
     
     
     
    function approveAndCall(address _spender, uint256 _amount, bytes _extraData
    ) returns (bool success) {
        require(approve(_spender, _amount));

        ApproveAndCallFallBack(_spender).receiveApproval(
            msg.sender,
            _amount,
            this,
            _extraData
        );

        return true;
    }

     
     
    function totalSupply() constant returns (uint) {
        return totalSupplyAt(block.number);
    }


 
 
 

     
     
     
     
    function balanceOfAt(address _owner, uint _blockNumber) constant
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

     
     
     
    function totalSupplyAt(uint _blockNumber) constant returns(uint) {

         
         
         
         
         
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

 
 
 

     
     
     
     
     
     
     
     
     
     
    function createCloneToken(
        string _cloneTokenName,
        uint8 _cloneDecimalUnits,
        string _cloneTokenSymbol,
        uint _snapshotBlock,
        bool _transfersEnabled
        ) returns(address) {
        if (_snapshotBlock == 0) _snapshotBlock = block.number;
        MiniMeToken cloneToken = tokenFactory.createCloneToken(
            this,
            _snapshotBlock,
            _cloneTokenName,
            _cloneDecimalUnits,
            _cloneTokenSymbol,
            _transfersEnabled
            );

        cloneToken.changeController(msg.sender);

         
        NewCloneToken(address(cloneToken), _snapshotBlock);
        return address(cloneToken);
    }

 
 
 

     
     
     
     
    function generateTokens(address _owner, uint _amount
    ) onlyController returns (bool) {
        uint curTotalSupply = totalSupply();
        require(curTotalSupply + _amount >= curTotalSupply);  
        uint previousBalanceTo = balanceOf(_owner);
        require(previousBalanceTo + _amount >= previousBalanceTo);  
        updateValueAtNow(totalSupplyHistory, curTotalSupply + _amount);
        updateValueAtNow(balances[_owner], previousBalanceTo + _amount);
        Transfer(0, _owner, _amount);
        return true;
    }


     
     
     
     
    function destroyTokens(address _owner, uint _amount
    ) onlyController returns (bool) {
        uint curTotalSupply = totalSupply();
        require(curTotalSupply >= _amount);
        uint previousBalanceFrom = balanceOf(_owner);
        require(previousBalanceFrom >= _amount);
        updateValueAtNow(totalSupplyHistory, curTotalSupply - _amount);
        updateValueAtNow(balances[_owner], previousBalanceFrom - _amount);
        Transfer(_owner, 0, _amount);
        return true;
    }

 
 
 


     
     
    function enableTransfers(bool _transfersEnabled) onlyController {
        transfersEnabled = _transfersEnabled;
    }

 
 
 

     
     
     
     
    function getValueAt(Checkpoint[] storage checkpoints, uint _block
    ) constant internal returns (uint) {
        if (checkpoints.length == 0) return 0;

         
        if (_block >= checkpoints[checkpoints.length-1].fromBlock)
            return checkpoints[checkpoints.length-1].value;
        if (_block < checkpoints[0].fromBlock) return 0;

         
        uint min = 0;
        uint max = checkpoints.length-1;
        while (max > min) {
            uint mid = (max + min + 1)/ 2;
            if (checkpoints[mid].fromBlock<=_block) {
                min = mid;
            } else {
                max = mid-1;
            }
        }
        return checkpoints[min].value;
    }

     
     
     
     
    function updateValueAtNow(Checkpoint[] storage checkpoints, uint _value
    ) internal  {
        if ((checkpoints.length == 0)
        || (checkpoints[checkpoints.length -1].fromBlock < block.number)) {
               Checkpoint storage newCheckPoint = checkpoints[ checkpoints.length++ ];
               newCheckPoint.fromBlock =  uint128(block.number);
               newCheckPoint.value = uint128(_value);
           } else {
               Checkpoint storage oldCheckPoint = checkpoints[checkpoints.length-1];
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

     
    function min(uint a, uint b) internal returns (uint) {
        return a < b ? a : b;
    }

     
     
     
    function ()  payable {
        require(isContract(controller));
        require(TokenController(controller).proxyPayment.value(msg.value)(msg.sender));
    }

 
 
 

     
     
     
     
    function claimTokens(address _token) onlyController {
        if (_token == 0x0) {
            controller.transfer(this.balance);
            return;
        }

        MiniMeToken token = MiniMeToken(_token);
        uint balance = token.balanceOf(this);
        token.transfer(controller, balance);
        ClaimedTokens(_token, controller, balance);
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
    ) returns (MiniMeToken) {
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

contract RealistoToken is MiniMeToken { 

   
  uint256 public checkpointBlock;

   
  address public mayGenerateAddr;

   
  bool tokenGenerationEnabled;  


  modifier mayGenerate() {
    require ( (msg.sender == mayGenerateAddr) &&
              (tokenGenerationEnabled == true) );  
    _;
  }

   
  function RealistoToken(address _tokenFactory) 
    MiniMeToken(
      _tokenFactory,
      0x0,
      0,
      "Realisto Token",
      18,  
      "REA",
       
      false){
    tokenGenerationEnabled = true;
    controller = msg.sender;
    mayGenerateAddr = controller;
  }

  function setGenerateAddr(address _addr) onlyController{
     
    require( _addr != 0x0 );
    mayGenerateAddr = _addr;
  }


   
   
  function () payable {
    revert();
  }

  
   
   
   
  function generate_token_for(address _addrTo, uint _amount) mayGenerate returns (bool) {
    
     
   
    uint curTotalSupply = totalSupply();
    require(curTotalSupply + _amount >= curTotalSupply);  
    uint previousBalanceTo = balanceOf(_addrTo);
    require(previousBalanceTo + _amount >= previousBalanceTo);  
    updateValueAtNow(totalSupplyHistory, curTotalSupply + _amount);
    updateValueAtNow(balances[_addrTo], previousBalanceTo + _amount);
    Transfer(0, _addrTo, _amount);
    return true;
  }

   
  function generateTokens(address _owner, uint _amount
    ) onlyController returns (bool) {
    revert();
    generate_token_for(_owner, _amount);    
  }


   
  function finalize() mayGenerate {
    tokenGenerationEnabled = false;  
    checkpointBlock = block.number;
  }  
}




 



 


 
contract TokenVault is Controlled {
	using SafeMath for uint256;


	 
	TokenCampaign campaign;
	 
	uint256 tDuration;
	uint256 tLock = 12 * 30 * (1 days);  
	MiniMeToken token;

	uint256 extracted = 0;

	event Extract(address indexed _to, uint256 _amount);

	function TokenVault(
		address _tokenAddress,
	 	address _campaignAddress,
	 	uint256 _tDuration
	 	) {

			require( _tDuration > 0);
			tDuration = _tDuration;

			 
			token = RealistoToken(_tokenAddress);
			campaign = TokenCampaign(_campaignAddress);
		}

	 
	 
	 
	 
	 
		 
		 
		 
	 
	 

	 
	function extract(address _to) onlyController {
		
		require (_to != 0x0);

		uint256 available = availableNow();
	
		require( available > 0 );

		extracted = extracted.add(available);
		assert( token.transfer(_to, available) );
		

		Extract(_to, available);

	}

	 
	function balance() returns (uint256){
		return token.balanceOf(address(this));
	}

	function get_unlock_time() returns (uint256){
		return campaign.tFinalized() + tLock;
	}

	 
	function availableNow() returns (uint256){
		
		uint256 tUnlock = get_unlock_time();
		uint256 tNow = now;

		 
		if (tNow < tUnlock ) { return 0; }

		uint256 remaining = balance();

		 
		if (tNow > tUnlock + tDuration) { return remaining; }

		 
		 

			 
		uint256 t = (tNow.sub(tUnlock)).mul(remaining.add(extracted));
		return (t.div(tDuration)).sub(extracted);
	}

}


contract rea_token_interface{
  uint8 public decimals;
  function generate_token_for(address _addr,uint _amount) returns (bool);
  function finalize();
}


 
contract TokenCampaign is Controlled{
  using SafeMath for uint256;

   
  rea_token_interface public token;

  TokenVault teamVault;

 
   
   
   

   
   
   

   
  uint256 public constant PRCT_TEAM = 10;
   
  uint256 public constant PRCT_BOUNTY = 3;
 
   
   
   
  uint256 public constant PRCT_ETH_OP = 10;

  uint8 public constant decimals = 18;
  uint256 public constant scale = (uint256(10) ** decimals);


   
   
  uint256 public constant baseRate = 330;  

   
   
   

  uint256 public constant bonusTokenThreshold = 2000000 * scale ;  

   
  uint256 public constant minContribution = (1 ether) / 100;

   
  uint256 public constant bonusMinContribution = (1 ether) /10;
   
  uint256 public constant bonusAdd = 99;  
  uint256 public constant stage_1_add = 50; 
  uint256 public constant stage_2_add = 33; 
  uint256 public constant stage_3_add = 18; 
  
   
   
   
   
   

   
   
  address public teamVaultAddr = 0x0;
  
   
  address public bountyVaultAddr;

   
  address public trusteeVaultAddr;
  
   
  address public opVaultAddr;
  

   
  address public tokenAddr;


   
   
   
   
  address public robotAddr;
  
  
   
   


   
   
   
   
   
   
   
  uint8 public campaignState = 4; 
  bool public paused = false;

   
  uint256 public tokensGenerated = 0;

   
  uint256 public amountRaised = 0; 

  
   
   
  
   
   
  uint256 public tCampaignStart = 64060588800;
  uint256 public tBonusStageEnd = 7 * (1 days);
  uint256 public tRegSaleStart = 8 * (1 days);
  uint256 public t_1st_StageEnd = 15 * (1 days);
  uint256 public t_2nd_StageEnd = 22* (1 days);
  uint256 public t_3rd_StageEnd = 29 * (1 days);
  uint256 public tCampaignEnd = 38 * (1 days);
  uint256 public tFinalized = 64060588800;

   
   
   

   
   
   
  modifier onlyRobot () { 
   require(msg.sender == robotAddr); 
   _;
  }

   
   
   
 
  event CampaignOpen(uint256 time);
  event CampaignClosed(uint256 time);
  event CampaignPausd(uint256 time);
  event CampaignResumed(uint256 time);
  event TokenGranted(address indexed backer, uint amount, string ref);
  event TokenGranted(address indexed backer, uint amount);
  event TotalRaised(uint raised);
  event Finalized(uint256 time);
  event ClaimedTokens(address indexed _token, address indexed _controller, uint _amount);
 

   
   
   
   
   
   
  function TokenCampaign(
    address _tokenAddress,
    address _trusteeAddress,
    address _opAddress,
    address _bountyAddress,
    address _robotAddress)
  {

    controller = msg.sender;
    
     
    tokenAddr = _tokenAddress;
     
    trusteeVaultAddr = _trusteeAddress; 
    opVaultAddr = _opAddress;
    bountyVaultAddr = _bountyAddress;
    robotAddr = _robotAddress;

     
    token = rea_token_interface(tokenAddr);
   
     
     
   
  }


   
   
   
  function get_presale_goal() constant returns (bool){
    if ((now <= tBonusStageEnd) && (tokensGenerated >= bonusTokenThreshold)){
      return true;
    } else {
      return false;
    }
  }

   
   
   
  function get_rate() constant returns (uint256){
    
     
     
     
    if (now < tCampaignStart) return 0;
    if (now > tCampaignEnd) return 0;
    
     
     
     
     
     
    if (now <= tBonusStageEnd)
      return scale * (baseRate + bonusAdd);

    if (now <= t_1st_StageEnd)
      return scale * (baseRate + stage_1_add);
    
    else if (now <= t_2nd_StageEnd)
      return scale * (baseRate + stage_2_add);
    
    else if (now <= t_3rd_StageEnd)
      return scale * (baseRate + stage_3_add);
    
    else 
      return baseRate * scale; 
  }


   
   
   

   
   
   


   
  function setRobotAddr(address _newRobotAddr) public onlyController {
    require( _newRobotAddr != 0x0 );
    robotAddr = _newRobotAddr;
  }

   
  function setTeamAddr(address _newTeamAddr) public onlyController {
     require( campaignState > 2 && _newTeamAddr != 0x0 );
     teamVaultAddr = _newTeamAddr;
     teamVault = TokenVault(teamVaultAddr);
  }
 


   
   
   
   
  function startSale() public onlyController {
     
    require( campaignState > 2 && teamVaultAddr != 0x0);

    campaignState = 2;

    uint256 tNow = now;
     
    tCampaignStart = tNow;
    tBonusStageEnd += tNow;
    tRegSaleStart += tNow;
    t_1st_StageEnd += tNow;
    t_2nd_StageEnd += tNow;
    t_3rd_StageEnd += tNow;
    tCampaignEnd += tNow;

    CampaignOpen(now);
  }


   
   
   
  function pauseSale() public onlyController {
    require( campaignState  == 2 );
    paused = true;
    CampaignPausd(now);
  }


   
  function resumeSale() public onlyController {
    require( campaignState  == 2 );
    paused = false;
    CampaignResumed(now);
  }



   
   
   
   
   
  function closeSale() public onlyController {
    require( campaignState  == 2 );
    campaignState = 1;

    CampaignClosed(now);
  }   



   
   
  function finalizeCampaign() public {     
      
       
       
       
      
      require ( (campaignState == 1) ||
                ((campaignState != 0) && (now > tCampaignEnd + (2880 minutes))));
      
      campaignState = 0;

     

       
       
       
       

      trusteeVaultAddr.transfer(this.balance);
      
      
      uint256 bountyTokens = (tokensGenerated.mul(PRCT_BOUNTY)).div(100);
      
      uint256 teamTokens = (tokensGenerated.mul(PRCT_TEAM)).div(100);
      
       
      assert( do_grant_tokens(bountyVaultAddr, bountyTokens) );
       
       
      
       
       
      
      tFinalized = now;

       
      assert( do_grant_tokens(teamVaultAddr, teamTokens) );
      
       
      token.finalize();     

       
      Finalized(tFinalized);
   }


   
   
   
   
  function do_grant_tokens(address _to, uint256 _nTokens) internal returns (bool){
    
    require( token.generate_token_for(_to, _nTokens) );
    
    tokensGenerated = tokensGenerated.add(_nTokens);
    
    return true;
  }


   
   
   
  function process_contribution(address _toAddr) internal {
    
    require ((campaignState == 2)    
         && (now <= tCampaignEnd)    
         && (paused == false));      
      

     
    if ( (now > tBonusStageEnd) &&  
         (now < tRegSaleStart)){  
      revert();  
    }

     
    if ((now <= tBonusStageEnd) && 
        ((msg.value < bonusMinContribution ) ||
        (tokensGenerated >= bonusTokenThreshold)))  
    {
      revert();
    }      

    
  
     
     
    require ( msg.value >= minContribution );

     
     
    uint256 rate = get_rate();
    
     
    uint256 nTokens = (rate.mul(msg.value)).div(1 ether);
    
     
    uint256 opEth = (PRCT_ETH_OP.mul(msg.value)).div(100);

     
    opVaultAddr.transfer(opEth);
    
     
     
    require( do_grant_tokens(_toAddr, nTokens) );


    amountRaised = amountRaised.add(msg.value);
    
     
    TokenGranted(_toAddr, nTokens);
    TotalRaised(amountRaised);
  }


   
   
   
   
   
   
   
   
   
  function grant_token_from_offchain(address _toAddr, uint _nTokens, string _ref) public onlyRobot {
    require ( (campaignState == 2)
              ||(campaignState == 1));

    do_grant_tokens(_toAddr, _nTokens);
    TokenGranted(_toAddr, _nTokens, _ref);
  }


   
   
   
  function proxy_contribution(address _toAddr) public payable {
    require ( _toAddr != 0x0 );
     
     
     
     
     
    require( msg.sender == tx.origin );
    process_contribution(_toAddr);
  }


   
  function () payable {
     
     
     
     
     
    require( msg.sender == tx.origin );
    process_contribution(msg.sender);  
  }

   
   
   

   

   
   
  function claimTokens(address _tokenAddr) public onlyController {
     
      
      
      
      

      ERC20Basic some_token = ERC20Basic(_tokenAddr);
      uint balance = some_token.balanceOf(this);
      some_token.transfer(controller, balance);
      ClaimedTokens(_tokenAddr, controller, balance);
  }
}