pragma solidity ^0.4.24;

import "../openzeppelin-solidity-master/contracts/token/ERC721/ERC721Token.sol";

contract MyERC721 is ERC721Token, ERC721Metadata {
    constructor (string _name, string _symbol) public
        ERC721Token(_name, _symbol)
    {
    }

    /**
    * Custom accessor to create a unique token
    */
    function mintUniqueTokenTo(
        address _to,
        uint256 _tokenId,
        string  _tokenURI
    ) public
    {
        super._mint(_to, _tokenId);
        super._setTokenURI(_tokenId, _tokenURI);
    }
}
