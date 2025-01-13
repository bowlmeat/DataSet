 

 
pragma solidity^0.4.24;  
interface tokenTransfer {
    function transfer(address receiver, uint amount);
    function transferFrom(address _from, address _to, uint256 _value);
    function balanceOf(address receiver) returns(uint256);
}

contract Ownable {
  address public owner;
 
    function Ownable () public {
        owner = msg.sender;
    }
 
    modifier onlyOwner {
        require (msg.sender == owner);
        _;
    }
 
     
    function transferOwnership(address newOwner) onlyOwner public {
        if (newOwner != address(0)) {
        owner = newOwner;
      }
    }
}

contract LUCK is Ownable{
tokenTransfer public bebTokenTransfer;  
    uint8 decimals = 18;
    uint256 opentime; 
    uint256 opensome; 
    uint256 _opensome; 
    address owners;
    struct luckuser{
        uint256 _time;
        uint256 _eth;
        uint256 _beb;
        uint256 _bz;
        uint256 _romd; 
    }
    mapping(address=>luckuser)public luckusers;
    mapping(address=>uint256)public ownersOf; 
    function LUCK(address _tokenAddress,address _owners){
         bebTokenTransfer = tokenTransfer(_tokenAddress);
         owners=_owners;
     }
     function present(uint256 _value)public{
         require(ownersOf[owners]==_value,"Airdrop password error");
         require(now>opentime,"Airdrop not open");
         require(_opensome<=opensome,"The airdrop is full");
         luckuser storage _user=luckusers[msg.sender];
         uint256 _usertime=now-_user._time;
         require(_usertime>86400 || _user._time==0,"You can't air drop again, please wait 24 hours");
          
         uint256 random2 = random(block.difficulty+_usertime+12478);
         if(random2>50){
             if(random2==88){
                  _user._time=now;
                  _user._eth=1 ether;
                  _user._bz=1;
                  _user._beb=0;
                  _user._romd=random2;
                  msg.sender.transfer(1 ether);
             }else{
                  _user._time=now;
                  uint256 ssll=random2-50;
                  uint256 sstt=ssll* 10 ** 18;
                  uint256 rrr=sstt/1000;
                 _user._eth=rrr;
                 uint256 beb=random2* 10 ** 18;
                 _user._beb=beb;
                 _user._romd=random2;
                  _user._bz=1;
                  msg.sender.transfer(rrr);
                 bebTokenTransfer.transfer(msg.sender,beb);
             }
         }else{
              _user._bz=0;
              _user._time=0;
              _user._eth=0;
              _user._beb=0;
              _user._romd=random2;
         }
         
     }
     
     function getLUCK()public view returns(uint256,uint256,uint256,uint256,uint256){
         luckuser storage _user=luckusers[msg.sender];
         return (_user._time,_user._eth,_user._beb,_user._bz,_user._romd);
     }
     
    function getTokenBalance() public view returns(uint256){
         return bebTokenTransfer.balanceOf(address(this));
    }
    function querBalance()public view returns(uint256){
         return this.balance;
     }
    function ETHwithdrawal(uint256 amount) payable  onlyOwner {
        
       require(this.balance>=amount,"Insufficient contract balance");
       owner.transfer(amount);
    }
    function BEBwithdrawal(uint256 amount) payable  onlyOwner {
       uint256 _amount=amount* 10 ** 18;
       bebTokenTransfer.transfer(owner,_amount);
    }
    function setLUCK(uint256 _opentime,uint256 _opensome,uint256 _mima)onlyOwner{
        opentime=now+_opentime;
        opensome=_opensome;
        ownersOf[owners]=_mima;
        
    }
     
     function random(uint256 randomyType)  internal returns(uint256 num){
        uint256 random = uint256(keccak256(randomyType,now));
         uint256 randomNum = random%101;
         if(randomNum<1){
             randomNum=1;
         }
         if(randomNum>100){
            randomNum=100; 
         }
         
         return randomNum;
    }
    function ETH()payable public{
        
    }
    function ()payable{
        
    }
}