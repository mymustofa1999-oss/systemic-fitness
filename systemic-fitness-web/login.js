const axios = require('axios');
async function run() {
    try {
        const res = await axios.post('http://localhost:8080/api/auth/login', {
            email: 'admin@systemicfitness.com',
            password: 'password123'
        });
        console.log(res.data.data.token);
    } catch (e) {
        console.error(e.response ? e.response.data : e.message);
    }
}
run();
