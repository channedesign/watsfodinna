import { Controller } from "@hotwired/stimulus";
export default class extends Controller {
    toggleSort(event) {
        const button = event.currentTarget;
        const sortBy = button.dataset.sortBy;
        const currentOrder = button.dataset.currentOrder;
    
        // Toggle between 'asc' and 'desc'
        const newOrder = currentOrder === 'desc' ? 'asc' : 'desc';
    
        // Update button's data-current-order attribute to reflect the new order
        button.dataset.currentOrder = newOrder;
    
        // Get the url with params and set the new ones
        const url = new URL(window.location);
        url.searchParams.set("sort_by", sortBy);
        url.searchParams.set("order", newOrder);
  
        fetch(url, {
            headers: {
            'Accept': 'application/json'
            }
        })
        .then(response => response.json())
        .then(data => {
            document.querySelector('#recipe-list').innerHTML = data.recipes_html;
            document.querySelector('#pagination').innerHTML = data.pagination_html;
        })
        .catch(error => {
            console.error('Error fetching recipes:', error);
        });
    }
}
