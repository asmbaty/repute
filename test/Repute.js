const Repute = artifacts.require('Repute');

contract('Repute', (accounts) => {
    let repute;

    let alice = accounts[0];
    let bob = accounts[1];
    let carol = accounts[2];
    let trudy = accounts[3];
    
    beforeEach('Setup contract for each test', async () => {
        repute = await Repute.new();
    });

    it('Alice and Bob have no ratings at the beginning', async () => {
        const alice_rating = await repute.getRating(alice);
        expect(alice_rating.toNumber()).to.equal(0);
        const bob_rating = await repute.getRating(bob);
        expect(bob_rating.toNumber()).to.equal(0);
    });

    it('Alice cannot rate Bob without a meeting', async () => {
        try {
            await repute.rate(bob, 1);
            expect.fail();
        } catch(error) {
            const ERROR_MEESAGE = 'Could not find a meeting with the ratee';
            expect(error.message).to.include(ERROR_MEESAGE);
        }
    });

    describe('Alice sends a meeting invitation to Bob', async () => {
        beforeEach('Alice sends an invitation', async () => {
            await repute.sendInvitation(bob);
        });

        it('Alice cannot send invitation to Bob twice', async () => {
            try {
                await repute.sendInvitation(bob);
                expect.fail();
            } catch(error) {
                const ERROR_MEESAGE = 'Invitation already exists';
                expect(error.message).to.include(ERROR_MEESAGE);
            }
        });

        it('Bob cannot send invitation to Alice', async () => {
            try {
                await repute.sendInvitation(alice, {from: bob});
                expect.fail();
            } catch(error) {
                const ERROR_MEESAGE = 'A reverse invitation already exists';
                expect(error.message).to.include(ERROR_MEESAGE);
            }
        });

        it('Alice can send invitation to Carol as well', async () => {
            await repute.sendInvitation(carol);
        });

        it('Alice can cancel the invitation', async () => {
            await repute.cancelInvitation(bob);
        });

        it('Bob can accept the invitation', async () => {
            await repute.acceptInvitation(alice, {from: bob});
        });

        it('Trudy cannot accept invitation', async () => {
            try {
                await repute.acceptInvitation(alice, {from: trudy});
                expect.fail();
            } catch(error) {
                const ERROR_MEESAGE = "Invitation doesn't exist";
                expect(error.message).to.include(ERROR_MEESAGE);
            }
        });

        xdescribe('Bob accepts the invitaiton', async () => {});
        xdescribe('Bob rejects the invitaiton', async () => {});
        xdescribe('Alice cancels the invitaiton', async () => {});
    });
})
