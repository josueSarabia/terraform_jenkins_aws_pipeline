const getProductsFromDB = require('../db').getProductsFromDB

test('get products from db', () => {
    let expected = {
        id:0,
        title: 'sofa 243',
        price: 156,
        color: 'yellow',
        type: 'sofa'
    }

    const getProducts = getProductsFromDB()

    expect(getProducts[0]).toEqual(expected);
});