import http from 'k6/http';
import { sleep } from 'k6';

export let options = {
    stages: [
        { duration: '20s', target: 5 },    // Ramp-up
        { duration: '1m', target: 30 },    // Spike
        { duration: '5m', target: 15 },    // Stay
    ],
};

export default function () {
    http.get('https://igazl-petstoreapp.calmgrass-55b43418.westeurope.azurecontainerapps.io/products?id=1&category=Toy');
    sleep(1);
    http.get('https://igazl-petstoreapp.calmgrass-55b43418.westeurope.azurecontainerapps.io/breeddetails?id=2&category=Dog');
    sleep(1);
    http.get('https://igazl-petstoreapp.calmgrass-55b43418.westeurope.azurecontainerapps.io/products?id=1&category=Food');
    sleep(1);
    http.get('https://igazl-petstoreapp.calmgrass-55b43418.westeurope.azurecontainerapps.io/cart');
    sleep(1);
    http.get('https://igazl-petstoreapp.calmgrass-55b43418.westeurope.azurecontainerapps.io/dogbreeds?category=Dog');
    sleep(1);
}