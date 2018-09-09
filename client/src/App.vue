<template>
  <div id="app">
    <md-toolbar md-elevation="0">
      <h1 class="md-title">Mascot Ranking Viewer</h1>
      <span class="subtitle">第6回学園祭マスコット総選挙非公式ランキング閲覧ツール</span>
    </md-toolbar>
    <h2><md-icon>insert_chart</md-icon> Chart</h2>
    <Chart :height="600"/>
    <Table/>
    <md-toolbar md-elevation="0">
      <p>Made by <a href="https://twitter.com/_nagatech" target="_blank">@_nagatech</a>. This site is not endorsed by nor affiliated with Mynavi Corporation.</p>
    </md-toolbar>
  </div>
</template>

<script>
import Chart from './components/Chart'
import Table from './components/Table'

export default {
  name: 'App',
  components: {
    Chart,
    Table
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
.subtitle {
  padding-left: 10px;
  color: #565656;
}
</style>
