pragma solidity ^0.4.24;

/**
 * Stores arbitrary data redundantly with multiple ethereum parties as
 *  'custodians'. Also, requires Unanimous consent among custodians to
 *    process any transaction.
 */
contract CustodianConsent {

    event Evaluated(bytes32 _hash);
    event Consented(bytes32 _hash);
    event CustodianAdded(address endpoint, bytes4 methodSignature);
    event ConsentsCleaned(bytes32 _hash);

    enum ConsentState {
        NONE,
        CONSENTED,
        EXECUTED
    }

    struct Custodian {
        address endpoint;
        bytes4 methodSignature;
    }

    Custodian[] custodians;

    mapping (bytes32 => mapping (address => ConsentState)) consentStates;

    modifier onlySelf {
        if (msg.sender == address(this)) {
            _;
        } else {
            throw;
        }
    }

    function CustodianConsent() {
    }

    function addCustodian(address _endpoint, bytes4 _methodSignature) external onlySelf {
        Custodian memory _custodian = Custodian(_endpoint, _methodSignature);
        custodians.push(_custodian);
        CustodianAdded(_endpoint, _methodSignature);
    }

    function cleanConsents(bytes32 _transHash) external onlySelf {
        for (uint j = custodians.length; j > 0; j--) {
            delete consentStates[_transHash][custodians[j-1].endpoint];
        }
        ConsentsCleaned(_transHash);
    }

    function consent(bytes32 _transHash) {
      if (consentStates[_transHash][msg.sender] == ConsentState.NONE) {
          consentStates[_transHash][msg.sender] = ConsentState.CONSENTED;
      } else {
          throw;
      }
      Consented(_transHash);
    }

    function eval(bytes32 _transHash) {
        bytes32 _hash = sha3(_transHash);
        uint i;
        uint c;
        uint r;

        for (i = custodians.length; i > 0; i--) {
            if (consentStates[_hash][custodians[i-1].endpoint] == ConsentState.CONSENTED) {
                consentStates[_hash][custodians[i-1].endpoint] = ConsentState.EXECUTED;
                ++c;
            } else {
              throw;
            }
        }

        for (i = custodians.length; i > 0; i--) {
          if (!(custodians[i].endpoint > 0 && custodians[i].endpoint.delegatecall(custodians[i].methodSignature, _transHash))) {
              throw;
          }
        }

        Evaluated(_hash);
    }

    function kill(address _recipient) external onlySelf {
        selfdestruct(_recipient);
    }
}
