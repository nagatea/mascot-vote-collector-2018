<script>
import axios from 'axios'
import { Line } from 'vue-chartjs'

axios.defaults.baseURL = process.env.BASE_URL

export default {
  name: 'Chart',
  extends: Line,
  async mounted () {
    const resp = await axios.get('/api/datasets')
    const options = {
      legend: {
        position: 'bottom',
        labels: {
          boxWidth: 20
        }
      },
      maintainAspectRatio: false
    }
    this.renderChart(resp.data, options)
  }
}
</script>
