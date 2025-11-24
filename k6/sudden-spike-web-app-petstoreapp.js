import http from 'k6/http';
import {sleep} from 'k6';

export let options = {
    stages: [
        {duration: '20s', target: 5},    // Ramp-up
        {duration: '1m', target: 10},    // Spike
        {duration: '5m', target: 5},    // Stay
    ],
};

let animals = {

    'Dog': {'lowest': 1, 'highest': 20},
    'Cat': {'lowest': 21, 'highest': 30},

}

let categories = ['Toy', 'Food'];

export default function () {

    let id = Math.floor(Math.random() * 30) + 1;
    let category = categories[Math.floor(Math.random() * categories.length)];
    let animalType = null;
    for (let animal in animals) {
        if (id >= animals[animal].lowest && id <= animals[animal].highest) {
            animalType = animal;
            break;
        }
    }
    console.log('id: ' + id + ', category: ' + category + ', animalType: ' + animalType);
    http.get('https://app-web-primary.azurewebsites.net/products?id=' + id + '+&category=' + category);
    sleep(1);
    http.get('https://app-web-primary.azurewebsites.net/breeddetails?id=' + id + '&category=' + animalType);
    sleep(1);
    http.get('https://app-web-primary.azurewebsites.net/cart');
    sleep(1);
    http.get('https://app-web-primary.azurewebsites.net/dogbreeds?category=' + animalType);
    sleep(1);
}