let playerLevel = 1;
let playerXP = 0;
let playerXPPercentage = 0;
let craftItems = [];
let selectedItem = null;
let productionTimer = null;
let isProducing = false;
let currentProduction = null;
let notificationQueue = [];
let isShowingNotification = false;
let currentCategory = 'all';
let searchTerm = '';

// NUI mesajlarını dinle
window.addEventListener('message', function(event) {
    const data = event.data;
    
    switch(data.action) {
        case 'openCraftMenu':
            openCraftMenu(data.location);
            break;
        case 'closeCraftMenu':
            closeCraftMenu();
            break;
        case 'updatePlayerLevel':
            updatePlayerLevel(data.data);
            break;
        case 'updateCraftItems':
            updateCraftItems(data.items);
            break;
        case 'showNotification':
            showNotification(data.message, data.type, data.duration);
            break;
    }
});

// Craft menüsünü aç
function openCraftMenu(locationName) {
    document.getElementById('craft-container').classList.remove('hidden');
    document.getElementById('location-name').textContent = locationName;
    
    // Üretim durumunu sıfırla
    isProducing = false;
    currentProduction = null;
    
    if (productionTimer) {
        clearTimeout(productionTimer);
        productionTimer = null;
    }
    
    // Timer'ı başlangıç durumuna getir
    const timerText = document.getElementById('timer-text');
    const timerFill = document.getElementById('timer-fill');
    const productionInfo = document.querySelector('.production-info');
    
    timerText.textContent = 'Bekliyor...';
    timerFill.style.width = '0%';
    productionInfo.classList.remove('producing');
    
    // Bildirim alanını temizle
    const notificationContent = document.getElementById('notification-content');
    notificationContent.innerHTML = '';
    document.getElementById('notification-box').style.display = 'none';
    notificationQueue = [];
    isShowingNotification = false;
    
    // Item detay box'ını gizle
    document.getElementById('item-detail-container').style.display = 'none';
    
    // Kategori ve arama durumunu sıfırla
    currentCategory = 'all';
    searchTerm = '';
    document.getElementById('search-input').value = '';
    updateCategoryTabs();
    
    // Craft butonunu güncelle
    updateCraftButton();
}

// Kategori tablarını güncelle
function updateCategoryTabs() {
    const tabs = document.querySelectorAll('.category-tab');
    tabs.forEach(tab => {
        tab.classList.remove('active');
        if (tab.dataset.category === currentCategory) {
            tab.classList.add('active');
        }
    });
}

// Craft menüsünü kapat
function closeCraftMenu() {
    // Üretim devam ediyorsa iptal et
    if (isProducing && productionTimer && currentProduction) {
        clearTimeout(productionTimer);
        productionTimer = null;
        
        // Server'a iptal mesajı gönder
        fetch(`https://${GetParentResourceName()}/cancelProduction`, {
            method: 'POST',
            headers: {
                'Content-Type': 'application/json'
            },
            body: JSON.stringify({
                itemName: currentProduction
            })
        });
    }
    
    // Üretim durumunu tamamen temizle
    isProducing = false;
    currentProduction = null;
    
    if (productionTimer) {
        clearTimeout(productionTimer);
        productionTimer = null;
    }
    
    const productionInfo = document.querySelector('.production-info');
    const timerFill = document.getElementById('timer-fill');
    const timerText = document.getElementById('timer-text');
    
    productionInfo.classList.remove('producing');
    timerFill.style.width = '0%';
    timerText.textContent = 'Bekliyor...';
    
    document.getElementById('craft-container').classList.add('hidden');
    fetch(`https://${GetParentResourceName()}/closeMenu`, {
        method: 'POST',
        headers: {
            'Content-Type': 'application/json'
        },
        body: JSON.stringify({})
    });
}

// Oyuncu level bilgilerini güncelle
function updatePlayerLevel(data) {
    playerLevel = data.level;
    playerXP = data.xp;
    playerXPPercentage = data.xpPercentage;
    
    document.getElementById('player-level').textContent = playerLevel;
    document.getElementById('xp-fill').style.width = playerXPPercentage + '%';
    
    // XP hesaplamasını güvenli hale getir
    let requiredXP = 100; // Varsayılan değer
    if (playerXPPercentage > 0) {
        requiredXP = Math.round(playerXP / (playerXPPercentage / 100));
    }
    
    document.getElementById('xp-text').textContent = `${playerXP}/${requiredXP} XP`;
}

// Craft itemlerini güncelle
function updateCraftItems(items) {
    craftItems = items;
    filterAndDisplayItems();
}

// Itemleri filtrele ve göster
function filterAndDisplayItems() {
    const container = document.getElementById('craft-items');
    container.innerHTML = '';
    
    const filteredItems = craftItems.filter(item => {
        const matchesCategory = currentCategory === 'all' || item.category === currentCategory;
        const matchesSearch = searchTerm === '' || 
            item.label.toLowerCase().includes(searchTerm.toLowerCase()) ||
            (item.category && item.category.toLowerCase().includes(searchTerm.toLowerCase()));
        
        return matchesCategory && matchesSearch;
    });
    
    filteredItems.forEach(item => {
        const itemElement = createCraftItemElement(item);
        container.appendChild(itemElement);
    });
}

// Craft item elementi oluştur
function createCraftItemElement(item) {
    const div = document.createElement('div');
    div.className = `craft-item ${item.canCraft ? '' : 'locked'}`;
    div.setAttribute('data-item', item.name);
    
    // Item resmi - yerel klasörden çek
    const imagePath = `./images/${item.image}`;
    
    div.innerHTML = `
        <img src="${imagePath}" alt="${item.label}" class="craft-item-image">
        <div class="craft-item-name">${item.label}</div>
        <div class="craft-item-level">Level ${item.level} Gerekli</div>
        <div class="craft-item-time">⏱️ ${item.productionTime || 0}s</div>
        <div class="craft-item-xp">+${item.xp} XP</div>

    `;
    
    // Click event - tüm itemler için detay göster
    div.addEventListener('click', () => {
        showItemDetails(item);
        if (item.canCraft) {
            selectItem(item);
        }
    });
    
    return div;
}

// Item detaylarını göster
function showItemDetails(item) {
    const container = document.getElementById('item-detail-container');
    const title = document.getElementById('item-detail-title');
    const content = document.getElementById('item-detail-content');
    
    title.textContent = item.label;
    
    content.innerHTML = `
        <div>📊 Level ${item.level} Gerekli</div>
        <div class="item-detail-ingredients">
            <div style="color: #ffffff; font-weight: bold; margin-bottom: 8px;">🔧 Gerekli Malzemeler:</div>
            ${Object.entries(item.ingredientsWithLabels || item.ingredients).map(([ingredient, data]) => {
                const amount = data.amount || data;
                const label = data.label || ingredient;
                // Her malzeme için ayrı kontrol yap
                const hasThisIngredient = item.ingredientStatus && item.ingredientStatus[ingredient];
                return `<div class="item-detail-ingredient ${hasThisIngredient ? 'available' : 'missing'}">• ${label}: ${amount}</div>`;
            }).join('')}
        </div>
        <div class="item-detail-status ${item.canCraft ? 'available' : 'unavailable'}">
            ${item.canCraft ? '✅ Üretilebilir' : '❌ Yetersiz Malzeme/Seviye'}
        </div>
    `;
    
    container.style.display = 'block';
}

// Item seç
function selectItem(item) {
    // Önceki seçimi temizle
    document.querySelectorAll('.craft-item').forEach(el => {
        el.classList.remove('selected');
    });
    
    // Yeni itemi seç
    const itemElement = document.querySelector(`[data-item="${item.name}"]`);
    if (itemElement) {
        itemElement.classList.add('selected');
    }
    
    selectedItem = item;
    updateCraftButton();
}

// Üret butonunu güncelle
function updateCraftButton() {
    const craftButton = document.getElementById('craft-button');
    
    if (isProducing) {
        craftButton.disabled = true;
        craftButton.innerHTML = `<i class="fas fa-clock"></i><span>Üretiliyor...</span>`;
    } else if (selectedItem && selectedItem.canCraft) {
        craftButton.disabled = false;
        craftButton.innerHTML = `<i class="fas fa-hammer"></i><span>ÜRET</span>`;
    } else {
        craftButton.disabled = true;
        craftButton.innerHTML = `<i class="fas fa-hammer"></i><span>ÜRET</span>`;
    }
}

// Üretim süresini başlat
function startProduction(itemName, productionTime) {
    if (isProducing) return;
    
    isProducing = true;
    currentProduction = itemName;
    
    const productionInfo = document.querySelector('.production-info');
    const timerFill = document.getElementById('timer-fill');
    const timerText = document.getElementById('timer-text');
    
    productionInfo.classList.add('producing');
    
    let timeLeft = productionTime;
    const totalTime = productionTime;
    
    function updateTimer() {
        if (timeLeft <= 0) {
            // Üretim tamamlandı
            completeProduction(itemName);
            return;
        }
        
        const percentage = ((totalTime - timeLeft) / totalTime) * 100;
        timerFill.style.width = percentage + '%';
        timerText.textContent = `${timeLeft}s`;
        
        timeLeft--;
        productionTimer = setTimeout(updateTimer, 1000);
    }
    
    updateTimer();
}

// Üretimi tamamla
function completeProduction(itemName) {
    isProducing = false;
    currentProduction = null;
    
    const productionInfo = document.querySelector('.production-info');
    const timerFill = document.getElementById('timer-fill');
    const timerText = document.getElementById('timer-text');
    
    productionInfo.classList.remove('producing');
    timerFill.style.width = '0%';
    timerText.textContent = 'Bekliyor...';
    
    if (productionTimer) {
        clearTimeout(productionTimer);
        productionTimer = null;
    }
    
    // Craft butonunu güncelle
    updateCraftButton();
    
    // Server'a üretim tamamlandı mesajı gönder
    fetch(`https://${GetParentResourceName()}/completeProduction`, {
        method: 'POST',
        headers: {
            'Content-Type': 'application/json'
        },
        body: JSON.stringify({
            itemName: itemName
        })
    });
}

// Item craft et
function craftItem(itemName) {
    // Üretim süresini başlat
    const item = craftItems.find(item => item.name === itemName);
    if (item && item.productionTime) {
        startProduction(itemName, item.productionTime);
    }
    
    // Craft butonunu devre dışı bırak
    const craftButton = document.getElementById('craft-button');
    craftButton.disabled = true;
    craftButton.innerHTML = `<i class="fas fa-clock"></i><span>Üretiliyor...</span>`;
    
    // Seçimi temizle
    selectedItem = null;
    document.querySelectorAll('.craft-item').forEach(el => {
        el.classList.remove('selected');
    });
}

// Close button event
document.getElementById('close-btn').addEventListener('click', closeCraftMenu);

// Craft button event
document.getElementById('craft-button').addEventListener('click', function() {
    if (selectedItem && selectedItem.canCraft) {
        craftItem(selectedItem.name);
    }
});

// ESC tuşu ile kapat
document.addEventListener('keydown', function(event) {
    if (event.key === 'Escape') {
        closeCraftMenu();
    }
});

// Bildirim sistemi
function showNotification(message, type = 'info', duration = 5000) {
    const notification = {
        message: message,
        type: type,
        duration: duration,
        id: Date.now() + Math.random()
    };
    
    notificationQueue.push(notification);
    
    if (!isShowingNotification) {
        processNotificationQueue();
    }
}

function processNotificationQueue() {
    if (notificationQueue.length === 0) {
        isShowingNotification = false;
        return;
    }
    
    isShowingNotification = true;
    const notification = notificationQueue.shift();
    
    const notificationBox = document.getElementById('notification-box');
    const notificationContent = document.getElementById('notification-content');
    
    // Yeni bildirim elementi oluştur
    const notificationElement = document.createElement('div');
    notificationElement.className = `notification-item ${notification.type}`;
    notificationElement.id = `notification-${notification.id}`;
    notificationElement.textContent = notification.message;
    
    // Bildirimi ekle
    notificationContent.appendChild(notificationElement);
    
    // Bildirim kutusunu göster
    notificationBox.style.display = 'block';
    
    // Belirtilen süre sonra bildirimi kaldır
    setTimeout(() => {
        if (notificationElement.parentNode) {
            notificationElement.style.opacity = '0';
            notificationElement.style.transform = 'translateY(-10px)';
            
            setTimeout(() => {
                if (notificationElement.parentNode) {
                    notificationElement.remove();
                    
                    // Eğer hiç bildirim kalmadıysa kutusu gizle
                    if (notificationContent.children.length === 0) {
                        notificationBox.style.display = 'none';
                    }
                }
                
                // Sıradaki bildirimi işle
                processNotificationQueue();
            }, 300);
        }
    }, notification.duration);
}

// GetParentResourceName helper
function GetParentResourceName() {
    return 'boa-craft';
}

// Kategori ve arama event listener'ları
document.addEventListener('DOMContentLoaded', function() {
    // Kategori tabları
    document.querySelectorAll('.category-tab').forEach(tab => {
        tab.addEventListener('click', function() {
            currentCategory = this.dataset.category;
            updateCategoryTabs();
            filterAndDisplayItems();
        });
    });
    
    // Arama input
    const searchInput = document.getElementById('search-input');
    searchInput.addEventListener('input', function() {
        searchTerm = this.value;
        filterAndDisplayItems();
    });
});
