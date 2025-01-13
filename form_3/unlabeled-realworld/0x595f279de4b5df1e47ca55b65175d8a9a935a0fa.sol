 
contract SomniumSpace is ERC721, ERC721Enumerable, ERC721Metadata, MinterRole, Ownable {
    constructor (string memory name, string memory symbol) public ERC721Metadata(name, symbol) Ownable() {
         
    }
    
     
    function mintWithTokenURI(address to, uint256 tokenId, string memory tokenURI, string memory tokenURLSomnium) public onlyMinter returns (bool) {
        _mint(to, tokenId);
        _setTokenURI(tokenId, tokenURI);
        _setTokenURLSomnium(tokenId, tokenURLSomnium);
        return true;
    }
}
