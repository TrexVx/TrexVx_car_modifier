let currentHandling = {};
let modifiedHandling = {};

document.addEventListener('DOMContentLoaded', () => {
    console.log('Script de handling cargado correctamente');
    
    document.getElementById('closeButton').addEventListener('click', closeMenu);
    document.getElementById('applyButton').addEventListener('click', applyHandlingChanges);
    document.getElementById('resetButton').addEventListener('click', resetHandling);
});

function closeMenu() {
    fetch(`https://${GetParentResourceName()}/closeMenu`, {
        method: 'POST',
        headers: {
            'Content-Type': 'application/json; charset=UTF-8',
        },
        body: JSON.stringify({})
    });
}

function applyHandlingChanges() {
    fetch(`https://${GetParentResourceName()}/modifyHandling`, {
        method: 'POST',
        headers: {
            'Content-Type': 'application/json; charset=UTF-8',
        },
        body: JSON.stringify({ handling: modifiedHandling })
    }).then(resp => resp.json()).then(resp => {
        if (resp.status === 'ok') {
            console.log('Handling modificado con éxito');
        } else {
            console.error('Error al modificar el handling:', resp.error);
        }
    });
}

function resetHandling() {
    modifiedHandling = {...currentHandling};
    updateButtonStates();
}

function createHandlingButtons(handling) {
    const container = document.getElementById('handling-controls');
    container.innerHTML = '';

    for (const [property, value] of Object.entries(handling)) {
        const button = document.createElement('button');
        button.className = 'handling-button';
        button.textContent = `${property}: ${value.toFixed(2)}`;
        button.addEventListener('click', () => toggleHandlingProperty(property));
        container.appendChild(button);
    }
    
    modifiedHandling = {...handling};
    updateButtonStates();
}

function toggleHandlingProperty(property) {
    if (modifiedHandling[property] === currentHandling[property]) {
        modifiedHandling[property] = currentHandling[property] * 1.1; // Increase by 10%
    } else if (modifiedHandling[property] > currentHandling[property]) {
        modifiedHandling[property] = currentHandling[property] * 0.9; // Decrease by 10%
    } else {
        modifiedHandling[property] = currentHandling[property]; // Reset to original
    }
    updateButtonStates();
}

function updateButtonStates() {
    const buttons = document.querySelectorAll('.handling-button');
    buttons.forEach(button => {
        const property = button.textContent.split(':')[0];
        const value = modifiedHandling[property];
        button.textContent = `${property}: ${value.toFixed(2)}`;
        if (value > currentHandling[property]) {
            button.classList.add('active');
            button.style.backgroundColor = '#00cc00'; // Green for increase
        } else if (value < currentHandling[property]) {
            button.classList.add('active');
            button.style.backgroundColor = '#cc0000'; // Red for decrease
        } else {
            button.classList.remove('active');
            button.style.backgroundColor = '';
        }
    });
}

window.addEventListener('message', (event) => {
    const item = event.data;
    if (item.type === "openMenu") {
        currentHandling = item.handling;
        createHandlingButtons(currentHandling);
        document.getElementById('app').style.display = 'block';
    } else if (item.type === "closeMenu") {
        document.getElementById('app').style.display = 'none';
    }
});