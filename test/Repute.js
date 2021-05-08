const Repute = artifacts.require('Repute');

contract('Repute', (accounts) => {
    let alice = accounts[0];
    let bob = accounts[1];
    let repute;
    
    beforeEach('Setup contract for each test', async () => {
        repute = await Repute.new();
    });

    it('Alice and Bob have no ratings at the beginning', async () => {
        const alice_rating = await repute.getRating(alice);
        assert.equal(alice_rating, 0);
        const bob_rating = await repute.getRating(bob);
        assert.equal(bob_rating, 0);
    });
})