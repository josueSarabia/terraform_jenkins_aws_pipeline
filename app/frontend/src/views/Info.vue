<template >
  <div class="container py-5" style="padding-top:70px;">

    <InfoBreadcrumb :information="information"/>
    <InfoBox :information="information"/>
    <InfoText />

    <div class="related-item">
      <hr>
      <h6 class="pb-4">RELATED PRODUCTS</h6>
      <Card :CardArray="sliceRelatedItems" />
    </div>

  </div>
</template>

<script>
import InfoBreadcrumb from '@/Components/InfoPage/InfoBreadcrumb.vue'
import InfoBox from '@/Components/InfoPage/InfoBox.vue'
import InfoText from '@/Components/InfoPage/InfoText.vue'
import Card from '@/Components/ProductsPage/Card.vue'
import axios from 'axios'


export default {
  name:'Info',
  components: {
    InfoBreadcrumb, InfoBox, InfoText, Card
  },
  data() {
    return {
      information: [],
      relatedItems: []
    }
  },
  created(){
    this.information = this.infO
    /* this.relatedItems = this.bringItems */
    const vm = this
    axios.get(process.env.VUE_APP_BASE_URL + '/products').then((res) => {
      vm.relatedItems = res.data.items
      for (let index = 0; index < vm.relatedItems.length; index++) {
        const element = vm.relatedItems[index];
        element.img = require(`@/assets/${index + 1}.jpg`)
      }
    })
    },
  computed: {
    infO() {
      return this.$store.getters.infoLength
    },
    /* bringItems() {
      return this.$store.state.items
    }, */
    sliceRelatedItems(){
      return this.relatedItems.slice(0 ,3)
    }
  },
  methods: {
    sendInfo(it, id) {
     this.$store.commit('addtoInfo', it, id)
    }
  }
}
</script>

<style scoped>
hr {
width: 50px;
border-bottom: 1px solid black;
}
.related-item{
  padding-left: 8rem;
  padding-right: 8rem;
  height: auto;
  text-align: center;
}
</style>
