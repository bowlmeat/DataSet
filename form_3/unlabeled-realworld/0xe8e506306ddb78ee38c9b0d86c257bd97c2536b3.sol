 

contract TheDAOHardForkOracle {
    address constant WithdrawDAO = 0xbf4ed7b27f1d666546e30d74d50d173d20bca754;
    address constant DarkDAO = 0x304a554a310c7e546dfe434669c62820b7d83490;

     
    bool public ran;
    bool public forked;
    bool public notforked;
    
    modifier after_dao_hf_block {
        if (block.number < 1920000) throw;
        _
    }
    
    modifier run_once {
        if (ran) throw;
        _
    }

    modifier has_millions(address _addr, uint _millions) {
        if (_addr.balance >= (_millions * 1000000 ether)) _
    }

     
     
     
    function check_withdrawdao() internal
        has_millions(WithdrawDAO, 10) {
        forked = true;
    }

     
     
     
    function check_darkdao() internal
        has_millions(DarkDAO, 3) {
        notforked = true;
    }

     
     
    function ()
        after_dao_hf_block run_once {
        ran = true;

        check_withdrawdao();
        check_darkdao();

         
        if (forked == notforked) throw;
    }
}