pragma solidity ^0.5.0;

import "truffle/Assert.sol";
import "truffle/DeployedAddresses.sol";
import "../contracts/SupplyChain.sol";

contract TestSupplyChain {

    // Test for failing conditions in this contracts:
    // https://truffleframework.com/tutorials/testing-for-throws-in-solidity-tests
    
    uint public initialBalance = 1 ether;
    SupplyChain sc;
    Buyer buyer;
    Seller seller;
    ThrowProxy throwproxy;

    function beforeAll() public{
        sc = SupplyChain(DeployedAddresses.SupplyChain());  
        throwproxy = new ThrowProxy(address(sc)); 
        seller = new Seller();
        //buyer = (new Buyer).value(100)();
        buyer = new Buyer();
        address(buyer).transfer(100);
        Assert.equal(address(seller).balance, 0, "Seller initial balance should be 0.");
        Assert.equal(address(buyer).balance, 100, "Buyer initial balance should be 100 wei.");

    }

    // buyItem
    // test for failure if user does not send enough funds
    function testForNotEnoughFunds() public {
        //Assert.fail("If test fails with this message, Assert.fail is working");
        seller.addItem(sc,"First Item", 200);
        buyer.buyItem(SupplyChain(address(throwproxy)), 0, 100);
        bool r = throwproxy.execute.gas(200000)();
        Assert.isFalse(r, "false because not enough funds were sent!");
        
    }
    // test for purchasing an item that is not for Sale

    // shipItem

    // test for calls that are made by not the seller
    // test for trying to ship an item that is not marked Sold

    // receiveItem

    // test calling the function from an address that is not the buyer
    // test calling the function on an item not marked Shipped

}

contract Buyer{
    constructor() public payable{}
    function buyItem(SupplyChain _sc, uint _sku, uint amount) public returns(bool){
        _sc.buyItem.value(amount)(_sku);
    }

    function receiveItem(SupplyChain _sc, uint _sku) public {

        _sc.receiveItem(_sku);
    }

    function  () external payable{}

}

contract Seller{
    constructor() public payable{}
    function addItem(SupplyChain _sc, string memory _item, uint _price) public returns (bool) {
        return _sc.addItem(_item, _price);
    }

    function shipItem(SupplyChain _sc, uint _sku) public {
        _sc.shipItem(_sku);
    }
    
    function  () external payable{}


}

// Proxy contract for testing throws
contract ThrowProxy {
  address public target;
  bytes data;

  constructor(address _target)  public {
    target = _target;
  }

  //prime the data using the fallback function.
  function() external {
    data = msg.data;
  }

  function execute() public returns (bool) {
    (bool r, bytes memory b)= target.call(data);
    return r;
  }
}
