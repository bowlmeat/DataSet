 

pragma solidity ^0.4.24;


contract SafeMath {
    function safeAdd(uint256 x, uint256 y) internal returns(uint256) {
        uint256 z = x + y;
        assert((z >= x) && (z >= y));
        return z;
    }

    function safeSubtract(uint256 x, uint256 y) internal returns(uint256) {
        assert(x >= y);
        uint256 z = x - y;
        return z;
    }

    function safeMult(uint256 x, uint256 y) internal returns(uint256) {
        uint256 z = x * y;
        assert((x == 0)||(z/x == y));
        return z;
    }

}

contract Token {
    uint256 public totalSupply;
    function balanceOf(address _owner) constant returns  (uint256 balance);
    function transfer(address _to, uint256 _value) returns (bool success);
    function transferFrom(address _from, address _to, uint256 _value) returns (bool success);
    function approve(address _spender, uint256 _value) returns (bool success);
    function allowance(address _owner, address _spender) constant returns (uint256 remaining);
    event Transfer(address indexed _from, address indexed _to, uint256 _value);
    event Approval(address indexed _owner, address indexed _spender, uint256 _value);

}


contract StandardToken is Token , SafeMath {
    function transfer(address _to, uint256 _value)  returns (bool success) {
        if (balances[msg.sender] >= _value && _value > 0 && _to != 0X0) {
            balances[msg.sender] -= _value;
            balances[_to] = safeAdd(balances[_to],_value);
            Transfer(msg.sender, _to, _value);
            return true;
        } else {
            return false;
        }
    }

    function transferFrom(address _from, address _to, uint256 _value)  returns (bool success) {
        if (balances[_from] >= _value && allowed[_from][msg.sender] >= _value && _value > 0) {
            balances[_to] = safeAdd(balances[_to],_value);
            balances[_from] = safeSubtract(balances[_from],_value);
            allowed[_from][msg.sender] = safeSubtract(allowed[_from][msg.sender],_value);
            Transfer(_from, _to, _value);
            return true;
        } else {
            return false;
        }
    }

    function balanceOf(address _owner)  constant returns (uint256 balance) {
        return balances[_owner];
    }

    function approve(address _spender, uint256 _value)  returns (bool success) {
        allowed[msg.sender][_spender] = _value;
        Approval(msg.sender, _spender, _value);
        return true;
    }

    function allowance(address _owner, address _spender)  constant returns (uint256 remaining) {
        return allowed[_owner][_spender];
    }

    mapping (address => uint256) balances;
    mapping (address => mapping (address => uint256)) allowed;
}


contract DVPToken is StandardToken {
    string public name = "Developer";
    uint8 public decimals = 18;
    string public symbol = "DVP";

    function DVPToken() {
        totalSupply = 84*10**24;
        balances[0x8357722B5eE6dC8fC0E75774B14De1f586002603] = totalSupply;
    }
}