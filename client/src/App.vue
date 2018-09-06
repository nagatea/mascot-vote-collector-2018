<template>
  <div id="app">
    <h2><md-icon>insert_chart</md-icon> Chart</h2>
    <Chart :height="600"/>
  </div>
</template>

<script>
import Chart from './components/Chart'

export default {
  name: 'App',
  components: {
    Chart
  }
}
</script>

<style>
#app {
  font-family: 'Avenir', Helvetica, Arial, sans-serif;
  -webkit-font-smoothing: antialiased;
  -moz-osx-font-smoothing: grayscale;
  color: #2c3e50;
}
</style>
