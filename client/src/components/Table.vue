<template>
  <div>
    <h2><md-icon class="md-size-2x">list_alt</md-icon>最新の集計結果({{ date.toFormat('YYYY-MM-DD') }})</h2>
    <md-table v-model="voteData" md-sort="vote" md-sort-order="desc" md-card>
      <md-table-row slot="md-table-row" slot-scope="{ item }">
        <md-table-cell md-label="Rank" md-sort-by="rank">{{ item.rank }} <span :style="{ color: getColor(item.rank_difference) }">{{ getRankDifference(item.rank_difference) }}</span></md-table-cell>
        <md-table-cell md-label="Name"><a :href="base_url + item.id" target="_blank">{{ item.name }}</a></md-table-cell>
        <md-table-cell md-label="Festival">{{ item.owner_name }}</md-table-cell>
        <md-table-cell md-label="Votes" md-sort-by="vote">{{ item.vote + ' ' + getDifference(item.difference)}}</md-table-cell>
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
      oldVoteData: [],
      base_url: 'https://contest.gakumado.mynavi.jp/mascot2018/photos/detail/'
    }
  },
  async created () {
    this.date = Date.yesterday()
    const resp = await axios.get(`/api/votes/${this.date.toFormat('YYYY-MM-DD')}`)
    this.voteData = resp.data
  },
  methods: {
    getDifference (diff) {
      if (diff > 0) {
        return `(+${diff})`
      } else if (diff === 0) {
        return '(±0)'
      } else {
        return `(${diff})`
      }
    },
    getRankDifference (diff) {
      if (diff > 0) {
        return `(↑${diff})`
      } else if (diff === 0) {
        return '(-)'
      } else {
        return `(↓${Math.abs(diff)})`
      }
    },
    getColor (diff) {
      if (diff > 0) {
        return '#ff0000'
      } else if (diff === 0) {
        return '#000000'
      } else {
        return '#0000ff'
      }
    }
  }
}
</script>

<style scoped>
</style>
