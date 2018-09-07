<template>
  <div>
    <h2><md-icon class="md-size-2x">list_alt</md-icon>最新の集計結果({{ date.toFormat('YYYY-MM-DD') }})</h2>
    <md-table v-model="voteData" md-sort="vote" md-sort-order="desc" md-card>
      <md-table-row slot="md-table-row" slot-scope="{ item }">
        <md-table-cell md-label="Rank" md-sort-by="rank">{{ item.rank }}</md-table-cell>
        <md-table-cell md-label="Name"><a :href="base_url + item.id" target="_blank">{{ item.name }}</a></md-table-cell>
        <md-table-cell md-label="Festival">{{ item.owner_name }}</md-table-cell>
        <md-table-cell md-label="Votes" md-sort-by="vote">{{ item.vote }}</md-table-cell>
      </md-table-row>
    </md-table>
  </div>
</template>

<script>
import axios from 'axios'
require('date-utils')
export default {
  name: 'Table',
  data () {
    return {
      date: null,
      voteData: [],
      base_url: 'https://contest.gakumado.mynavi.jp/mascot2018/photos/detail/'
    }
  },
  async created () {
    this.date = new Date()
    this.date.setDate(this.date.getDate() - 1)
    const resp = await axios.get(`/api/votes?date=${this.date.toFormat('YYYY-MM-DD')}`)
    this.voteData = resp.data
  }
}
</script>

<style scoped>
</style>
