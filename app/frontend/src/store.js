import Vue from 'vue';
import Vuex from 'vuex';
// import createPersistedState from 'vuex-persistedstate';

Vue.use(Vuex);

export default new Vuex.Store({
  state: {
    infoPage:[],
    cartItems:[],
  },
  // plugins: [createPersistedState()],
  getters: {
    itemsNumber(state){  // Cart Component
      return state.cartItems.length
    },
    totalPrice(state) { // Cart Component
      if (state.cartItems.length != 0){
       return state.cartItems.reduce((a, b) => {
         return (b.price == null ) ? a : a + b.price
       }, 0)
      }
    },
    infoLength(state) { // Info Component
      if(state.infoPage.length > 0) {
        return state.infoPage.splice(0, 1)
      }
    }
  },
  mutations: {
    inCart(state, n) { // Cart Component
      return state.cartItems.push(n)
    },
    outCart(state, n) { // Cart Component
      let index = state.cartItems.findIndex(x => x.id === n)
      return state.cartItems.splice(index, 1)
    },
    addtoInfo(state, n) { // Info Component
       return state.infoPage.push(n)
    }
  },
})
