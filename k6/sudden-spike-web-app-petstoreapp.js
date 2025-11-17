import http from 'k6/http';
import { sleep } from 'k6';

export let options = {
    stages: [
        { duration: '20s', target: 5 },    // Ramp-up
        { duration: '1m', target: 25 },    // Spike
        { duration: '5m', target: 15 },    // Stay
    ],
};

export default function () {
    http.get('https://app-web-primary.azurewebsites.net/products?id=1&category=Toy');
    sleep(1);
    http.get('https://app-web-primary.azurewebsites.net/breeddetails?id=2&category=Dog');
    sleep(1);
    http.get('https://app-web-primary.azurewebsites.net/products?id=1&category=Food');
    sleep(1);
    http.get('https://app-web-primary.azurewebsites.net/cart');
    sleep(1);
    http.get('https://app-web-primary.azurewebsites.net/dogbreeds?category=Dog');
    sleep(1);
}