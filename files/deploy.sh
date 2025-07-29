#!/bin/bash
# Este script é projetado para ser usado como EC2 User Data para configurar um servidor web
# e implantar uma aplicação web de uma única página, com o HTML embutido diretamente no script.

# --- Variáveis de Configuração ---
APP_DIR="/var/www/acme-corp-webapp" # Diretório onde a aplicação será criada
PORT=8001 # Porta em que o servidor Python irá escutar

# --- 1. Atualizar Pacotes do Sistema ---
echo "Atualizando pacotes do sistema..."
sudo apt-get update -y
echo "Pacotes do sistema atualizados."

# --- 2. Instalar Python3 ---
echo "Instalando Python3..."
sudo apt-get install -y python3
echo "Python3 instalado."

# --- 3. Criar o Diretório da Aplicação ---
echo "Criando o diretório da aplicação: /${APP_DIR}..."
sudo mkdir -p /${APP_DIR}
sudo chown -R ubuntu:ubuntu /${APP_DIR} # Garante que o usuário ubuntu possa escrever/ler
cd /${APP_DIR}
echo "Diretório da aplicação criado."

# --- 4. Criar o arquivo index.html diretamente ---
echo "Criando o arquivo index.html..."
sudo bash -c "cat > /${APP_DIR}/index.html" <<'EOF'
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>ACME Corp Widgets</title>
    <!-- Tailwind CSS CDN -->
    <script src="https://cdn.tailwindcss.com"></script>
    <style>
        /* Custom styles for the Inter font and smooth transitions */
        body {
            font-family: 'Inter', sans-serif;
            @apply bg-gray-50 text-gray-800;
        }
        .modal {
            display: none; /* Hidden by default */
            position: fixed; /* Stay in place */
            z-index: 1000; /* Sit on top */
            left: 0;
            top: 0;
            width: 100%; /* Full width */
            height: 100%; /* Full height */
            overflow: auto; /* Enable scroll if needed */
            background-color: rgba(0,0,0,0.4); /* Black w/ opacity */
            @apply flex justify-center items-center p-4;
        }
        .modal-content {
            @apply bg-white p-6 rounded-xl shadow-2xl max-w-lg w-full relative;
        }
        .close-button {
            @apply absolute top-3 right-3 text-gray-500 hover:text-gray-800 text-2xl font-bold cursor-pointer;
        }
    </style>
</head>
<body>
    <!-- Header -->
    <header class="bg-gradient-to-r from-blue-600 to-indigo-700 text-white shadow-lg py-4">
        <div class="container mx-auto flex flex-col sm:flex-row justify-between items-center px-4">
            <h1 class="text-3xl font-extrabold mb-2 sm:mb-0">ACME Corp</h1>
            <nav class="space-x-4">
                <a href="#products" class="hover:text-blue-200 transition-colors duration-200">Products</a>
                <a href="#orders" class="hover:text-blue-200 transition-colors duration-200">My Orders</a>
                <button onclick="openCartModal()" class="bg-white text-blue-700 py-2 px-4 rounded-full font-semibold shadow-md hover:bg-blue-100 transition duration-300 ease-in-out transform hover:scale-105">
                    Cart (<span id="cart-count">0</span>)
                </button>
            </nav>
        </div>
    </header>

    <!-- Hero Section -->
    <section class="bg-gradient-to-br from-blue-500 to-purple-600 text-white py-20 text-center shadow-inner">
        <div class="container mx-auto px-4">
            <h2 class="text-4xl sm:text-5xl md:text-6xl font-extrabold leading-tight mb-4 animate-fade-in-down">
                Revolutionizing Your World with ACME Widgets
            </h2>
            <p class="text-lg sm:text-xl md:text-2xl mb-8 opacity-90 animate-fade-in-up">
                Discover the power of innovation. Quality, reliability, and cutting-edge technology.
            </p>
            <a href="#products" class="bg-white text-blue-700 py-3 px-8 rounded-full font-bold text-lg shadow-xl hover:bg-blue-100 transition duration-300 ease-in-out transform hover:scale-105">
                Explore Our Widgets
            </a>
        </div>
    </section>

    <!-- Products Section -->
    <section id="products" class="py-16 bg-gray-50">
        <div class="container mx-auto px-4">
            <h3 class="text-4xl font-bold text-center text-gray-900 mb-12">Our Amazing Widgets</h3>
            <div id="product-grid" class="grid grid-cols-1 sm:grid-cols-2 lg:grid-cols-3 xl:grid-cols-4 gap-8">
                <!-- Product cards will be injected here by JavaScript -->
            </div>
        </div>
    </section>

    <!-- My Orders Section -->
    <section id="orders" class="py-16 bg-gray-100">
        <div class="container mx-auto px-4">
            <h3 class="text-4xl font-bold text-center text-gray-900 mb-12">Your Recent Orders</h3>
            <div id="orders-list" class="space-y-6">
                <p id="no-orders-message" class="text-center text-gray-600 text-lg">No orders placed yet in this session.</p>
                <!-- Orders will be injected here by JavaScript -->
            </div>
        </div>
    </section>

    <!-- Footer -->
    <footer class="bg-gray-800 text-white py-8 mt-16">
        <div class="container mx-auto text-center px-4">
            <p>&copy; <span id="current-year"></span> ACME Corp. All rights reserved.</p>
            <p class="text-sm mt-2">Built for a Terraform Demo</p>
        </div>
    </footer>

    <!-- Cart Modal -->
    <div id="cart-modal" class="modal">
        <div class="modal-content">
            <span class="close-button" onclick="closeCartModal()">&times;</span>
            <h4 class="text-3xl font-bold text-gray-900 mb-6">Your Shopping Cart</h4>
            <div id="cart-items" class="max-h-80 overflow-y-auto pr-2 mb-6 space-y-4">
                <p id="empty-cart-message" class="text-gray-600 text-center">Your cart is empty.</p>
                <!-- Cart items will be injected here -->
            </div>
            <div class="flex justify-between items-center border-t pt-4 mt-4">
                <p class="text-xl font-semibold">Total: $<span id="cart-total">0.00</span></p>
                <button
                    onclick="placeOrder()"
                    id="place-order-button"
                    class="bg-green-600 hover:bg-green-700 text-white font-semibold py-3 px-6 rounded-lg shadow-md transition duration-300 ease-in-out transform hover:scale-105 focus:outline-none focus:ring-2 focus:ring-green-500 focus:ring-opacity-75 disabled:opacity-50 disabled:cursor-not-allowed"
                    disabled
                >
                    Place Order
                </button>
            </div>
        </div>
    </div>

    <!-- Order Confirmation Modal -->
    <div id="order-confirmation-modal" class="modal">
        <div class="modal-content text-center">
            <span class="close-button" onclick="closeOrderConfirmationModal()">&times;</span>
            <svg class="mx-auto mb-4 text-green-500" xmlns="http://www.w3.org/2000/svg" width="64" height="64" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" stroke-linecap="round" stroke-linejoin="round"><path d="M22 11.08V12a10 10 0 1 1-5.93-9.14"></path><polyline points="22 4 12 14.01 9 11.01"></polyline></svg>
            <h4 class="text-3xl font-bold text-gray-900 mb-4">Order Placed Successfully!</h4>
            <p class="text-lg text-gray-700 mb-6">Thank you for your purchase. Your order ID is: <span id="confirmed-order-id" class="font-mono font-bold text-blue-600"></span></p>
            <button
                onclick="closeOrderConfirmationModal()"
                class="bg-blue-600 hover:bg-blue-700 text-white font-semibold py-3 px-6 rounded-lg shadow-md transition duration-300 ease-in-out transform hover:scale-105 focus:outline-none focus:ring-2 focus:ring-blue-500 focus:ring-opacity-75"
            >
                Continue Shopping
            </button>
        </div>
    </div>

    <script>
        /**
         * @file This script powers the ACME Corp Widgets website, handling product display,
         * shopping cart functionality, order placement simulation, and modal interactions.
         * @author Gemini
         */

        // --- Data Definitions ---
        /**
         * Represents a product available for sale.
         * @typedef {Object} Product
         * @property {number} id - Unique identifier for the product.
         * @property {string} name - Name of the product.
         * @property {number} price - Price of the product.
         * @property {string} description - Brief description of the product.
         * @property {string} imageUrl - URL for the product image.
         */
        const products = [
            { id: 1, name: "Standard Widget", price: 29.99, description: "Our classic, reliable widget for everyday needs. Essential for any toolkit.", imageUrl: "https://placehold.co/400x300/F0F4F8/334155?text=Widget+A" },
            { id: 2, name: "Premium Widget Pro", price: 49.99, description: "Enhanced performance and durability for professionals. Built to last.", imageUrl: "https://placehold.co/400x300/F0F4F8/334155?text=Widget+B" },
            { id: 3, name: "Mini Widget", price: 15.00, description: "Compact and portable, perfect for on-the-go tasks. Fits in your pocket!", imageUrl: "https://placehold.co/400x300/F0F4F8/334155?text=Widget+C" },
            { id: 4, name: "Smart Widget X", price: 75.50, description: "AI-powered widget with advanced features. The future is here.", imageUrl: "https://placehold.co/400x300/F0F4F8/334155?text=Widget+D" },
            { id: 5, name: "Eco Widget", price: 35.00, description: "Environmentally friendly widget, made from recycled materials.", imageUrl: "https://placehold.co/400x300/F0F4F8/334155?text=Widget+E" },
            { id: 6, name: "Industrial Widget", price: 120.00, description: "Heavy-duty widget designed for robust industrial applications.", imageUrl: "https://placehold.co/400x300/F0F4F8/334155?text=Widget+F" }
        ];

        /**
         * Represents an item in the shopping cart.
         * @typedef {Object} CartItem
         * @property {number} productId - The ID of the product.
         * @property {number} quantity - The quantity of the product in the cart.
         * @property {number} price - The price of a single unit of the product at the time of adding.
         */
        let cart = []; // Stores CartItem objects

        /**
         * Represents a placed order (for session display only).
         * @typedef {Object} Order
         * @property {string} orderId - Unique ID for the order.
         * @property {Array<Object>} items - Array of items in the order (e.g., {name, quantity, price}).
         * @property {number} total - Total cost of the order.
         * @property {string} date - Date and time the order was placed.
         */
        let orders = []; // Stores Order objects

        // --- DOM Elements ---
        const productGrid = document.getElementById('product-grid');
        const cartCountSpan = document.getElementById('cart-count');
        const cartItemsContainer = document.getElementById('cart-items');
        const cartTotalSpan = document.getElementById('cart-total');
        const emptyCartMessage = document.getElementById('empty-cart-message');
        const placeOrderButton = document.getElementById('place-order-button');
        const cartModal = document.getElementById('cart-modal');
        const orderConfirmationModal = document.getElementById('order-confirmation-modal');
        const confirmedOrderIdSpan = document.getElementById('confirmed-order-id');
        const ordersList = document.getElementById('orders-list');
        const noOrdersMessage = document.getElementById('no-orders-message');

        // --- Initialization ---
        document.addEventListener('DOMContentLoaded', () => {
            renderProducts();
            updateCartDisplay();
            updateOrdersDisplay();
            document.getElementById('current-year').textContent = new Date().getFullYear();
        });

        // --- Product Rendering ---
        /**
         * Renders all products from the `products` array into the product grid.
         */
        function renderProducts() {
            if (!productGrid) {
                console.error("Product grid element not found.");
                return;
            }
            productGrid.innerHTML = ''; // Clear existing content
            products.forEach(product => {
                const productCard = `
                    <div class="bg-white rounded-xl shadow-lg overflow-hidden flex flex-col transform transition-transform duration-300 hover:scale-105">
                        <img src="${product.imageUrl}" alt="${product.name}" class="w-full h-48 object-cover">
                        <div class="p-6 flex flex-col flex-grow">
                            <h4 class="text-xl font-bold text-gray-900 mb-2">${product.name}</h4>
                            <p class="text-gray-600 text-sm mb-4 flex-grow">${product.description}</p>
                            <div class="flex justify-between items-center mt-auto pt-4 border-t border-gray-100">
                                <span class="text-2xl font-extrabold text-blue-700">$${product.price.toFixed(2)}</span>
                                <button
                                    onclick="addToCart(${product.id})"
                                    class="bg-blue-600 hover:bg-blue-700 text-white font-semibold py-2 px-4 rounded-lg shadow-md transition duration-300 ease-in-out transform hover:scale-105 focus:outline-none focus:ring-2 focus:ring-blue-500 focus:ring-opacity-75"
                                >
                                    Add to Cart
                                </button>
                            </div>
                        </div>
                    </div>
                `;
                productGrid.insertAdjacentHTML('beforeend', productCard);
            });
        }

        // --- Cart Management ---
        /**
         * Adds a product to the shopping cart or increments its quantity if already present.
         * @param {number} productId - The ID of the product to add.
         */
        function addToCart(productId) {
            const product = products.find(p => p.id === productId);
            if (product) {
                const existingItem = cart.find(item => item.productId === productId);
                if (existingItem) {
                    existingItem.quantity++;
                } else {
                    cart.push({ productId: productId, quantity: 1, price: product.price });
                }
                updateCartDisplay();
                openCartModal(); // Open cart modal automatically
            } else {
                console.error(`Product with ID ${productId} not found.`);
            }
        }

        /**
         * Removes an item from the cart.
         * @param {number} productId - The ID of the product to remove.
         */
        function removeFromCart(productId) {
            cart = cart.filter(item => item.productId !== productId);
            updateCartDisplay();
        }

        /**
         * Updates the quantity of a product in the cart.
         * @param {number} productId - The ID of the product.
         * @param {number} change - The amount to change the quantity by (e.g., 1 for increment, -1 for decrement).
         */
        function updateCartQuantity(productId, change) {
            const item = cart.find(item => item.productId === productId);
            if (item) {
                item.quantity += change;
                if (item.quantity <= 0) {
                    removeFromCart(productId);
                } else {
                    updateCartDisplay();
                }
            }
        }

        /**
         * Updates the display of the cart count, items, and total.
         */
        function updateCartDisplay() {
            if (!cartCountSpan || !cartItemsContainer || !cartTotalSpan || !emptyCartMessage || !placeOrderButton) {
                console.error("One or more cart display elements not found.");
                return;
            }

            cartCountSpan.textContent = cart.reduce((sum, item) => sum + item.quantity, 0);
            cartItemsContainer.innerHTML = ''; // Clear current items

            if (cart.length === 0) {
                emptyCartMessage.style.display = 'block';
                placeOrderButton.disabled = true;
            } else {
                emptyCartMessage.style.display = 'none';
                placeOrderButton.disabled = false;
                let total = 0;
                cart.forEach(item => {
                    const product = products.find(p => p.id === item.productId);
                    if (product) {
                        const itemTotal = item.quantity * item.price;
                        total += itemTotal;
                        const cartItemHtml = `
                            <div class="flex items-center justify-between p-3 bg-gray-50 rounded-lg shadow-sm">
                                <div class="flex items-center">
                                    <img src="${product.imageUrl}" alt="${product.name}" class="w-12 h-12 object-cover rounded-md mr-4">
                                    <div>
                                        <p class="font-semibold text-gray-800">${product.name}</p>
                                        <p class="text-sm text-gray-600">$${item.price.toFixed(2)} each</p>
                                    </div>
                                </div>
                                <div class="flex items-center space-x-2">
                                    <button onclick="updateCartQuantity(${item.productId}, -1)" class="bg-gray-200 text-gray-700 w-8 h-8 rounded-full flex items-center justify-center hover:bg-gray-300 transition-colors">-</button>
                                    <span class="font-medium text-gray-900">${item.quantity}</span>
                                    <button onclick="updateCartQuantity(${item.productId}, 1)" class="bg-gray-200 text-gray-700 w-8 h-8 rounded-full flex items-center justify-center hover:bg-gray-300 transition-colors">+</button>
                                    <button onclick="removeFromCart(${item.productId})" class="text-red-500 hover:text-red-700 ml-2">
                                        <svg xmlns="http://www.w3.org/2000/svg" width="20" height="20" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" stroke-linecap="round" stroke-linejoin="round"><path d="M3 6h18"></path><path d="M19 6v14c0 1-1 2-2 2H7c-1 0-2-1-2-2V6"></path><path d="M8 6V4c0-1 1-2 2-2h4c1 0 2 1 2 2v2"></path></svg>
                                    </button>
                                </div>
                            </div>
                        `;
                        cartItemsContainer.insertAdjacentHTML('beforeend', cartItemHtml);
                    }
                });
                cartTotalSpan.textContent = total.toFixed(2);
            }
        }

        // --- Order Placement ---
        /**
         * Simulates placing an order. Clears the cart and adds the order to the session's orders list.
         */
        function placeOrder() {
            if (cart.length === 0) {
                console.warn("Cannot place an empty order.");
                return;
            }

            const orderItems = cart.map(item => {
                const product = products.find(p => p.id === item.productId);
                return {
                    name: product ? product.name : 'Unknown Product',
                    quantity: item.quantity,
                    price: item.price
                };
            });

            const orderTotal = parseFloat(cartTotalSpan.textContent);
            const orderId = generateOrderId();
            const orderDate = new Date().toLocaleString();

            orders.push({
                orderId: orderId,
                items: orderItems,
                total: orderTotal,
                date: orderDate
            });

            cart = []; // Clear the cart
            updateCartDisplay();
            updateOrdersDisplay();
            closeCartModal();
            openOrderConfirmationModal(orderId);
        }

        /**
         * Generates a simple unique order ID.
         * @returns {string} A unique order ID.
         */
        function generateOrderId() {
            return 'ACME-' + Math.random().toString(36).substr(2, 9).toUpperCase();
        }

        // --- Order Display ---
        /**
         * Updates the display of past orders.
         */
        function updateOrdersDisplay() {
            if (!ordersList || !noOrdersMessage) {
                console.error("Orders list or no orders message element not found.");
                return;
            }

            ordersList.innerHTML = ''; // Clear existing orders

            if (orders.length === 0) {
                noOrdersMessage.style.display = 'block';
            } else {
                noOrdersMessage.style.display = 'none';
                orders.forEach(order => {
                    const orderItemsHtml = order.items.map(item => `
                        <li class="text-gray-700 text-sm ml-4">&bull; ${item.name} (x${item.quantity}) - $${(item.quantity * item.price).toFixed(2)}</li>
                    `).join('');

                    const orderCard = `
                        <div class="bg-white rounded-xl shadow-md p-6 border border-gray-200">
                            <div class="flex justify-between items-center mb-4 pb-4 border-b border-gray-100">
                                <h5 class="text-xl font-bold text-gray-900">Order ID: <span class="font-mono text-blue-600">${order.orderId}</span></h5>
                                <span class="text-gray-500 text-sm">${order.date}</span>
                            </div>
                            <p class="font-semibold text-gray-800 mb-2">Items:</p>
                            <ul class="list-none mb-4">
                                ${orderItemsHtml}
                            </ul>
                            <div class="text-right text-lg font-bold text-gray-900">
                                Total: <span class="text-green-600">$${order.total.toFixed(2)}</span>
                            </div>
                        </div>
                    `;
                    ordersList.insertAdjacentHTML('beforeend', orderCard);
                });
            }
        }

        // --- Modal Functions ---
        /**
         * Opens the cart modal.
         */
        function openCartModal() {
            if (cartModal) {
                cartModal.style.display = 'flex';
            }
        }

        /**
         * Closes the cart modal.
         */
        function closeCartModal() {
            if (cartModal) {
                cartModal.style.display = 'none';
            }
        }

        /**
         * Opens the order confirmation modal with the given order ID.
         * @param {string} orderId - The ID of the confirmed order.
         */
        function openOrderConfirmationModal(orderId) {
            if (orderConfirmationModal && confirmedOrderIdSpan) {
                confirmedOrderIdSpan.textContent = orderId;
                orderConfirmationModal.style.display = 'flex';
            }
        }

        /**
         * Closes the order confirmation modal.
         */
        function closeOrderConfirmationModal() {
            if (orderConfirmationModal) {
                orderConfirmationModal.style.display = 'none';
            }
        }

        // Close modals when clicking outside the content
        window.onclick = function(event) {
            if (event.target === cartModal) {
                closeCartModal();
            }
            if (event.target === orderConfirmationModal) {
                closeOrderConfirmationModal();
            }
        };
    </script>
</body>
</html>
EOF
echo "Arquivo index.html criado."

# --- 5. Iniciar o Servidor HTTP Python ---
echo "Iniciando o servidor HTTP Python na porta /${PORT}..."
# Navega para o diretório da aplicação e inicia o servidor Python em segundo plano
# usando nohup para que continue rodando mesmo após o user_data terminar
# e redirecionando a saída para um log.
# O '0.0.0.0' garante que o servidor escute em todas as interfaces de rede.
nohup python3 -m http.server --bind 0.0.0.0 /${PORT} > /var/log/python_http_server.log 2>&1 &
echo "Servidor HTTP Python iniciado em segundo plano na porta /${PORT}."

echo "Implantação da aplicação web concluída!"
echo "Você agora deve ser capaz de acessar seu site ACME Corp Widgets através do endereço IP público da instância EC2 na porta /${PORT}."
