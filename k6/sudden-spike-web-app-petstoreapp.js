import http from 'k6/http';
import { sleep } from 'k6';

export let options = {
    stages: [
        { duration: '20s', target: 55 },    // Ramp-up
        { duration: '1m', target: 500 },    // Spike
        { duration: '5m', target: 700 },    // Stay
    ],
};

export default function () {
    http.get('http://tm-app-web-igazl.trafficmanager.net/products?id=1&category=Toy');
    sleep(1);
    http.get('http://tm-app-web-igazl.trafficmanager.net/breeddetails?id=2&category=Dog');
    sleep(1);
    http.get('http://tm-app-web-igazl.trafficmanager.net/products?id=1&category=Food');
    sleep(1);
    http.get('http://tm-app-web-igazl.trafficmanager.net/cart');
    sleep(1);
    http.get('http://tm-app-web-igazl.trafficmanager.net/dogbreeds?category=Dog');
    sleep(1);
}