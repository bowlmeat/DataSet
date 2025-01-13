 

pragma solidity ^0.4.8;

 
contract SafeMath {
  function safeMul(uint256 a, uint256 b) internal returns (uint256) {
    uint256 c = a * b;
    assert(a == 0 || c / a == b);
    return c;
  }

  function safeDiv(uint256 a, uint256 b) internal returns (uint256) {
    assert(b > 0);
    uint256 c = a / b;
    assert(a == b * c + a % b);
    return c;
  }

  function safeSub(uint256 a, uint256 b) internal returns (uint256) {
    assert(b <= a);
    return a - b;
  }

  function safeAdd(uint256 a, uint256 b) internal returns (uint256) {
    uint256 c = a + b;
    assert(c>=a && c>=b);
    return c;
  }

  function assert(bool assertion) internal {
    if (!assertion) {
      throw;
    }
  }
}
contract BITXOXO is SafeMath{
    string public name;
    string public symbol;
    uint8 public decimals;
    uint256 public totalSupply;
    address public owner;
     

     
    mapping (address => uint256) public balanceOf;
    mapping (address => mapping (address => uint256)) public allowance;

     
    event Transfer(address indexed from, address indexed to, uint256 value);



     
    function BITXOXO() {
        balanceOf[msg.sender] = 20000000000000000000000000;               
        totalSupply = 20000000000000000000000000;                         
        name = "BITXOXO";                                    
        symbol = "XOXO";                                
        decimals = 18;                             
        owner = msg.sender;
    }

     
    function transfer(address _to, uint256 _value) {
        if (_to == 0x0) throw;                                
		if (_value <= 0) throw; 
        if (balanceOf[msg.sender] < _value) throw;            
        if (balanceOf[_to] + _value < balanceOf[_to]) throw;  
        balanceOf[msg.sender] = SafeMath.safeSub(balanceOf[msg.sender], _value);                      
        balanceOf[_to] = SafeMath.safeAdd(balanceOf[_to], _value);                             
        Transfer(msg.sender, _to, _value);                    
    }

     
    function approve(address _spender, uint256 _value)
        returns (bool success) {
		if (_value <= 0) throw; 
        allowance[msg.sender][_spender] = _value;
        return true;
    }
       

     
    function transferFrom(address _from, address _to, uint256 _value) returns (bool success) {
        if (_to == 0x0) throw;                                 
		if (_value <= 0) throw; 
        if (balanceOf[_from] < _value) throw;                  
        if (balanceOf[_to] + _value < balanceOf[_to]) throw;   
        if (_value > allowance[_from][msg.sender]) throw;      
        balanceOf[_from] = SafeMath.safeSub(balanceOf[_from], _value);                            
        balanceOf[_to] = SafeMath.safeAdd(balanceOf[_to], _value);                              
        allowance[_from][msg.sender] = SafeMath.safeSub(allowance[_from][msg.sender], _value);
        Transfer(_from, _to, _value);
        return true;
    }

  
	 
    function distributeToken(address[] addresses, uint256[] _value) onlyCreator {
     for (uint i = 0; i < addresses.length; i++) {
         balanceOf[msg.sender] -= _value[i];
         balanceOf[addresses[i]] += _value[i];
         Transfer(msg.sender, addresses[i], _value[i]);
        }
    }

modifier onlyCreator() {
        require(msg.sender == owner);   
        _;
    }
	
	 
    function withdrawEther(uint256 amount) {
		if(msg.sender != owner)throw;
		owner.transfer(amount);
    }
	
	 
	function() payable {
    }

    function transferOwnership(address newOwner) onlyCreator public {
        require(newOwner != address(0));
        uint256 _leftOverTokens = balanceOf[msg.sender];
        balanceOf[newOwner] = SafeMath.safeAdd(balanceOf[newOwner], _leftOverTokens);                             
        balanceOf[msg.sender] = SafeMath.safeSub(balanceOf[msg.sender], _leftOverTokens);                      
        Transfer(msg.sender, newOwner, _leftOverTokens);     
        owner = newOwner;
    }

}