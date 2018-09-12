<template>
  <div id="index">
    <h2><md-icon>insert_chart</md-icon> Chart</h2>
    <Chart :height="600"/>
    <Table/>
  </div>
</template>

<script>
import Chart from '@/components/Chart'
import Table from '@/components/Table'

export default {
  name: 'Index',
  components: {
    Chart,
    Table
  }
}
</script>

<style>
</style>
