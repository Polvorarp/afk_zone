// Iconos de items (puedes personalizarlos)
const itemIcons = {
    'water': '💧',
    'bread': '🍞',
    'sandwich': '🥪',
    'bandage': '🩹',
    'phone': '📱',
    'lockpick': '🔓',
    'weapon_pistol': '🔫',
    'money': '💵',
    'default': '📦'
};

let activeTimers = {};

window.addEventListener('message', function(event) {
    const data = event.data;
    
    switch(data.action) {
        case 'showUI':
            showAFKZone(data.data);
            break;
        case 'hideUI':
            hideAFKZone();
            break;
        case 'updateTime':
            updateTime(data.time, data.rewards);
            break;
        case 'updateTimer':
            updateIndividualTimer(data.id, data.currentTime, data.totalTime, data.timeRemaining);
            break;
        case 'newReward':
            showRewardNotification(data.item, data.label, data.amount, data.timerId);
            break;
    }
});

function showAFKZone(data) {
    const container = document.getElementById('afk-container');
    container.classList.remove('hidden');
    
    // Cargar bonus items
    const bonusContainer = document.getElementById('bonus-items');
    bonusContainer.innerHTML = '';
    
    if (data.bonusItems && data.bonusItems.length > 0) {
        data.bonusItems.forEach(bonus => {
            const bonusDiv = document.createElement('div');
            bonusDiv.className = 'bonus-item';
            bonusDiv.innerHTML = `<span class="bonus-item-icon">${itemIcons[bonus.item] || itemIcons.default}</span>`;
            bonusDiv.title = bonus.label;
            bonusContainer.appendChild(bonusDiv);
        });
    }
    
    // Crear timers individuales
    const rewardsList = document.getElementById('rewards-list');
    rewardsList.innerHTML = '';
    
    if (data.timers && data.timers.length > 0) {
        data.timers.forEach(timer => {
            const timerDiv = createTimerElement(timer);
            rewardsList.appendChild(timerDiv);
            activeTimers[timer.id] = timer;
        });
    }
}

function createTimerElement(timer) {
    const div = document.createElement('div');
    div.className = 'reward-timer-item';
    div.id = `timer-${timer.id}`;
    
    const totalMinutes = Math.floor(timer.time / 60000);
    const icon = itemIcons[timer.item] || itemIcons.default;
    
    div.innerHTML = `
        <div class="reward-timer-header">
            <span class="reward-item-name">${icon} ${timer.label}</span>
            <span class="reward-item-time" id="time-${timer.id}">${totalMinutes}:00</span>
        </div>
        <div class="reward-progress-bar">
            <div class="reward-progress-fill" id="progress-${timer.id}"></div>
        </div>
    `;
    
    return div;
}

function hideAFKZone() {
    const container = document.getElementById('afk-container');
    container.classList.add('hidden');
    activeTimers = {};
}

function updateTime(timeInSeconds, rewardCount) {
    // Actualizar tiempo en minutos
    const minutes = Math.floor(timeInSeconds / 60);
    document.getElementById('afk-time').textContent = minutes;
    
    // Actualizar contador de recompensas
    document.getElementById('reward-count').textContent = rewardCount;
}

function updateIndividualTimer(id, currentTime, totalTime, timeRemaining) {
    const progressBar = document.getElementById(`progress-${id}`);
    const timeDisplay = document.getElementById(`time-${id}`);
    const timerElement = document.getElementById(`timer-${id}`);
    
    if (!progressBar || !timeDisplay || !timerElement) return;
    
    // Calcular progreso
    const progress = (currentTime / totalTime) * 100;
    progressBar.style.width = `${progress}%`;
    
    // Formatear tiempo restante
    const mins = Math.floor(timeRemaining / 60);
    const secs = timeRemaining % 60;
    timeDisplay.textContent = `${mins}:${secs.toString().padStart(2, '0')}`;
    
    // Agregar clase "active" si está en progreso
    if (progress > 0) {
        timerElement.classList.add('active');
    }
    
    // Agregar clase "near-complete" si está cerca de completarse (>80%)
    if (progress > 80) {
        timerElement.classList.add('near-complete');
    } else {
        timerElement.classList.remove('near-complete');
    }
}

function showRewardNotification(item, label, amount, timerId) {
    const notification = document.getElementById('reward-notification');
    const description = document.getElementById('reward-desc');
    
    // Resetear el timer que se completó
    if (timerId) {
        const progressBar = document.getElementById(`progress-${timerId}`);
        const timerElement = document.getElementById(`timer-${timerId}`);
        
        if (progressBar && timerElement) {
            // Animación de completado
            timerElement.style.animation = 'pulse 0.5s ease-out';
            
            setTimeout(() => {
                progressBar.style.width = '0%';
                timerElement.classList.remove('active', 'near-complete');
                timerElement.style.animation = '';
            }, 500);
        }
    }
    
    // Mostrar notificación
    const icon = itemIcons[item] || itemIcons.default;
    description.textContent = `${amount}x ${label}`;
    document.querySelector('.reward-icon').textContent = icon;
    notification.classList.remove('hidden');
    
    // Ocultar después de 3 segundos
    setTimeout(() => {
        notification.classList.add('hidden');
    }, 3000);
}

// Tips rotativos
const tips = [
    "No te muevas para mantener tus beneficios",
    "Tus necesidades están congeladas aquí",
    "Cada item tiene su propio tiempo de espera",
    "Este es un lugar seguro para estar AFK",
    "Algunos items tardan más que otros",
    "Puedes obtener múltiples recompensas simultáneamente"
];

let currentTipIndex = 0;

setInterval(() => {
    currentTipIndex = (currentTipIndex + 1) % tips.length;
    const tipElement = document.getElementById('tip-message');
    if (tipElement) {
        tipElement.style.opacity = '0';
        setTimeout(() => {
            tipElement.textContent = tips[currentTipIndex];
            tipElement.style.opacity = '1';
        }, 300);
    }
}, 10000); // Cambiar tip cada 10 segundos

// Animación suave del texto
const tipMessage = document.getElementById('tip-message');
if (tipMessage) {
    tipMessage.style.transition = 'opacity 0.3s ease';
}