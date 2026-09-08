const axios = require('axios');
axios.post("http://localhost:8080/api/digital-library/movements", {
  name: "testcase",
  body_part: "lower",
  categories: ["MC"],
  target_gender: "universal"
}).then(res => console.log(res.data)).catch(err => console.log(err.response.data));
