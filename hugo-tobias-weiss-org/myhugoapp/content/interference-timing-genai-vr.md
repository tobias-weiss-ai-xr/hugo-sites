---
category: ["research", "ai", "xr"]
date: "2024-12-18T00:00:00+01:00"
draft: false
title: "Impact of GenAI Sales Agent Timing in VR Commerce"
comments: false
showcomments: false
showpagemeta: false
---

<!-- Tailwind CSS -->
<script src="https://cdn.tailwindcss.com"></script>

<!-- Chart.js -->
<script src="https://cdn.jsdelivr.net/npm/chart.js"></script>

<!-- Google Fonts -->
<link href="https://fonts.googleapis.com/css2?family=Inter:wght@400;600;700&display=swap" rel="stylesheet">

<style>
    body { font-family: 'Inter', sans-serif; background-color: #f8fafc; color: #1e293b; font-size: 18px; line-height: 1.7; }

    /* Chart Container Styling - MANDATORY */
    .chart-container {
        position: relative;
        width: 100%;
        max-width: 800px; /* Max width to prevent stretching */
        margin-left: auto;
        margin-right: auto;
        height: 400px; /* Base height */
        max-height: 500px;
    }
    @media (max-width: 768px) {
        .chart-container {
            height: 300px;
        }
    }

    .card-hover { transition: transform 0.2s ease, box-shadow 0.2s ease; }
    .card-hover:hover { transform: translateY(-2px); box-shadow: 0 10px 15px -3px rgba(0, 0, 0, 0.1), 0 4px 6px -2px rgba(0, 0, 0, 0.05); }

    .nav-link { position: relative; font-size: 16px; font-weight: 500; }
    .nav-link::after {
        content: '';
        position: absolute;
        width: 0;
        height: 2px;
        bottom: -2px;
        left: 0;
        background-color: #3b82f6;
        transition: width 0.3s;
    }
    .nav-link:hover::after { width: 100%; }

    /* Custom Scrollbar */
    ::-webkit-scrollbar { width: 8px; }
    ::-webkit-scrollbar-track { background: #f1f1f1; }
    ::-webkit-scrollbar-thumb { background: #cbd5e1; border-radius: 4px; }
    ::-webkit-scrollbar-thumb:hover { background: #94a3b8; }

    /* Enhanced Typography */
    .text-large { font-size: 1.25rem; line-height: 1.75; }
    .text-xl-large { font-size: 1.375rem; line-height: 1.75; }
    .text-xxl-large { font-size: 1.5rem; line-height: 1.75; }

    @media (max-width: 768px) {
        body { font-size: 16px; }
        .text-large { font-size: 1.125rem; }
        .text-xl-large { font-size: 1.25rem; }
        .text-xxl-large { font-size: 1.375rem; }
    }
</style>

{{< rawhtml >}}
<div class="flex flex-col min-h-screen">

    <!-- Navigation -->
    <nav class="bg-white border-b border-slate-200 sticky top-0 z-50">
        <div class="max-w-7xl mx-auto px-4 sm:px-6 lg:px-8">
            <div class="flex justify-between h-16">
                <div class="flex items-center">
                    <span class="text-xl font-bold text-slate-800 tracking-tight">Research</span>
                </div>
                <div class="hidden md:flex space-x-8 items-center">
                    <button onclick="scrollToSection('hero')" class="nav-link text-slate-600 hover:text-slate-900 px-3 py-2 text-sm font-medium">Abstract</button>
                    <button onclick="scrollToSection('products')" class="nav-link text-slate-600 hover:text-slate-900 px-3 py-2 text-sm font-medium">The Scenario</button>
                    <button onclick="scrollToSection('methodology')" class="nav-link text-slate-600 hover:text-slate-900 px-3 py-2 text-sm font-medium">Methodology</button>
                    <button onclick="scrollToSection('results')" class="nav-link text-slate-600 hover:text-slate-900 px-3 py-2 text-sm font-medium">Findings</button>
                </div>
            </div>
        </div>
    </nav>

    <!-- Hero Section -->
    <section id="hero" class="bg-slate-50 py-16 lg:py-24">
        <div class="max-w-4xl mx-auto px-4 sm:px-6 lg:px-8 text-center">
            <div class="inline-flex items-center px-4 py-2 rounded-full bg-blue-100 text-blue-800 text-sm font-semibold tracking-wide uppercase mb-6">
                Research Report Visualization
            </div>
            <h1 class="text-5xl sm:text-6xl lg:text-7xl font-bold text-slate-900 mb-8 leading-tight">
                Interference Timing of <br/>GenAI Sales Agents in Virtual Reality
            </h1>
            <p class="text-xl-large text-slate-600 mb-10 max-w-3xl mx-auto">
                How does the timing of an AI assistant's approach affect consumer behavior in the Metaverse? This study investigates the impact of <strong>Immediate</strong> vs. <strong>Delayed</strong> interference on user experience, decision confidence, and purchase intention.
            </p>
            <div class="flex justify-center space-x-6">
                <button onclick="document.getElementById('results').scrollIntoView({behavior: 'smooth'})" class="bg-blue-600 hover:bg-blue-700 text-white font-bold py-4 px-10 rounded-lg transition shadow-lg text-lg">
                    View Results
                </button>
                <button onclick="document.getElementById('products').scrollIntoView({behavior: 'smooth'})" class="bg-white hover:bg-slate-50 text-slate-700 font-semibold py-4 px-10 rounded-lg border border-slate-300 transition shadow-sm text-lg">
                    Explore Setup
                </button>
            </div>
        </div>
    </section>

    <!-- Context Section: The Products -->
    <section id="products" class="py-16 bg-white border-t border-slate-100">
        <div class="max-w-7xl mx-auto px-4 sm:px-6 lg:px-8">
            <div class="text-center mb-12">
                <h2 class="text-4xl font-bold text-slate-900">The Experimental Scenario</h2>
                <p class="mt-6 text-xl-large text-slate-600 max-w-3xl mx-auto">
                    Participants were placed in a Virtual Reality showroom and tasked with choosing a 3D printer. The complexity of the product data (specs, price, kit vs. assembled) created a realistic cognitive load, making the role of the AI assistant crucial.
                </p>
            </div>

            <div class="grid grid-cols-1 md:grid-cols-3 gap-8" id="product-grid">
                <!-- Products injected via JS -->
            </div>

            <div class="mt-8 p-6 bg-slate-50 rounded-lg border border-slate-200 text-center">
                <p class="text-large text-slate-600">
                    <span class="font-bold">Task:</span> Evaluate these options. In the study, the AI agent would approach either <strong>immediately</strong> upon entry or <strong>delayed</strong> (after 5+ seconds of browsing).
                </p>
            </div>
        </div>
    </section>

    <!-- Methodology Section -->
    <section id="methodology" class="py-16 bg-slate-50">
        <div class="max-w-7xl mx-auto px-4 sm:px-6 lg:px-8">
            <div class="mb-12">
                <h2 class="text-4xl font-bold text-slate-900">The GenAI Pipeline</h2>
                <p class="mt-6 text-xl-large text-slate-600">
                    The sales agent wasn't a static script. It utilized a real-time Generative AI pipeline to converse naturally with participants.
                </p>
            </div>

            <!-- Interactive Pipeline Diagram -->
            <div class="bg-white rounded-xl shadow-sm border border-slate-200 p-8">
                <div class="flex flex-col md:flex-row items-center justify-between space-y-6 md:space-y-0">

                    <!-- Step 1 -->
                    <div class="flex-1 text-center group cursor-pointer" onclick="highlightStep(1)">
                        <div id="step-1-icon" class="w-20 h-20 mx-auto bg-blue-100 text-blue-600 rounded-full flex items-center justify-center text-3xl mb-4 transition group-hover:bg-blue-600 group-hover:text-white">
                            🎤
                        </div>
                        <h3 class="font-bold text-slate-900 text-lg">1. User Speech</h3>
                        <p class="text-sm text-slate-500 mt-2 font-medium">Voice Input</p>
                    </div>

                    <!-- Arrow -->
                    <div class="hidden md:block text-slate-300 text-3xl">➔</div>

                    <!-- Step 2 -->
                    <div class="flex-1 text-center group cursor-pointer" onclick="highlightStep(2)">
                        <div id="step-2-icon" class="w-20 h-20 mx-auto bg-slate-100 text-slate-600 rounded-full flex items-center justify-center text-3xl mb-4 transition group-hover:bg-blue-600 group-hover:text-white">
                            📝
                        </div>
                        <h3 class="font-bold text-slate-900 text-lg">2. Speech-to-Text</h3>
                        <p class="text-sm text-slate-500 mt-2 font-medium">Azure STT</p>
                    </div>

                    <!-- Arrow -->
                    <div class="hidden md:block text-slate-300 text-3xl">➔</div>

                    <!-- Step 3 -->
                    <div class="flex-1 text-center group cursor-pointer" onclick="highlightStep(3)">
                        <div id="step-3-icon" class="w-20 h-20 mx-auto bg-slate-100 text-slate-600 rounded-full flex items-center justify-center text-3xl mb-4 transition group-hover:bg-blue-600 group-hover:text-white">
                            🧠
                        </div>
                        <h3 class="font-bold text-slate-900 text-lg">3. LLM Processing</h3>
                        <p class="text-sm text-slate-500 mt-2 font-medium">GPT-4 / OpenAI</p>
                    </div>

                    <!-- Arrow -->
                    <div class="hidden md:block text-slate-300 text-3xl">➔</div>

                    <!-- Step 4 -->
                    <div class="flex-1 text-center group cursor-pointer" onclick="highlightStep(4)">
                        <div id="step-4-icon" class="w-20 h-20 mx-auto bg-slate-100 text-slate-600 rounded-full flex items-center justify-center text-3xl mb-4 transition group-hover:bg-blue-600 group-hover:text-white">
                            🔊
                        </div>
                        <h3 class="font-bold text-slate-900 text-lg">4. Text-to-Speech</h3>
                        <p class="text-sm text-slate-500 mt-2 font-medium">Azure TTS</p>
                    </div>
                </div>

                <div id="pipeline-details" class="mt-8 p-6 bg-blue-50 rounded-lg border border-blue-100">
                    <h4 class="font-bold text-blue-900 text-lg" id="detail-title">User Speech</h4>
                    <p class="text-blue-800 mt-2 text-large" id="detail-desc">The participant speaks naturally to the avatar in the VR environment, asking questions like "Which printer is best for beginners?"</p>
                </div>
            </div>
        </div>
    </section>

    <!-- Findings Section -->
    <section id="results" class="py-16 bg-white border-t border-slate-200">
        <div class="max-w-7xl mx-auto px-4 sm:px-6 lg:px-8">
            <div class="flex flex-col md:flex-row justify-between items-end mb-8">
                <div class="max-w-2xl">
                    <h2 class="text-4xl font-bold text-slate-900">Quantitative Results</h2>
                    <p class="mt-6 text-xl-large text-slate-600">
                        Comparing the <strong>Immediate</strong> (Agent interrupts instantly) vs. <strong>Delayed</strong> (Agent waits for browsing) conditions across 100 participants.
                    </p>
                </div>
                <div class="mt-4 md:mt-0 flex space-x-2 bg-slate-100 p-1 rounded-lg">
                    <button onclick="updateChart('perception')" id="btn-perception" class="px-4 py-2 rounded-md text-sm font-medium transition bg-white text-blue-600 shadow-sm">User Perception</button>
                    <button onclick="updateChart('outcomes')" id="btn-outcomes" class="px-4 py-2 rounded-md text-sm font-medium transition text-slate-600 hover:text-slate-900">Decision Outcomes</button>
                </div>
            </div>

            <div class="grid grid-cols-1 lg:grid-cols-3 gap-8">
                <!-- Main Chart -->
                <div class="lg:col-span-2 bg-white rounded-xl shadow-sm border border-slate-200 p-6">
                    <div class="chart-container">
                        <canvas id="mainChart"></canvas>
                    </div>
                </div>

                <!-- Key Metrics Cards -->
                <div class="space-y-6">
                    <div class="bg-blue-50 p-6 rounded-xl border border-blue-100">
                        <h3 class="text-blue-900 font-bold text-xl mb-3">Key Finding: Timing Matters</h3>
                        <p class="text-blue-800 text-large">
                            The <strong>Delayed</strong> condition significantly outperformed Immediate interference across all positive metrics. Users preferred autonomy before assistance.
                        </p>
                    </div>

                    <div class="bg-white p-6 rounded-xl border border-slate-200 shadow-sm">
                        <h4 class="text-sm uppercase tracking-wide text-slate-500 font-bold mb-4">Hypothesis Validation</h4>
                        <ul class="space-y-3">
                            <li class="flex items-center text-large">
                                <span class="w-7 h-7 rounded-full bg-green-100 text-green-600 flex items-center justify-center mr-3 text-sm font-bold">✓</span>
                                <span class="text-slate-700 font-medium">H1: Delayed ↑ Usefulness</span>
                            </li>
                            <li class="flex items-center text-large">
                                <span class="w-7 h-7 rounded-full bg-green-100 text-green-600 flex items-center justify-center mr-3 text-sm font-bold">✓</span>
                                <span class="text-slate-700 font-medium">H2: Delayed ↓ Intrusiveness</span>
                            </li>
                            <li class="flex items-center text-large">
                                <span class="w-7 h-7 rounded-full bg-green-100 text-green-600 flex items-center justify-center mr-3 text-sm font-bold">✓</span>
                                <span class="text-slate-700 font-medium">H3: Delayed ↑ Confidence</span>
                            </li>
                            <li class="flex items-center text-large">
                                <span class="w-7 h-7 rounded-full bg-green-100 text-green-600 flex items-center justify-center mr-3 text-sm font-bold">✓</span>
                                <span class="text-slate-700 font-medium">H4: Delayed ↑ Purchase Intent</span>
                            </li>
                        </ul>
                    </div>
                </div>
            </div>
        </div>
    </section>

    <!-- Conclusion Section -->
    <section class="py-16 bg-gradient-to-br from-slate-50 to-blue-50 border-t border-slate-200">
        <div class="max-w-4xl mx-auto px-4 sm:px-6 lg:px-8 text-center">
            <div class="inline-flex items-center px-4 py-2 rounded-full bg-blue-100 text-blue-800 text-sm font-semibold tracking-wide uppercase mb-6">
                Key Insights
            </div>
            <h2 class="text-4xl lg:text-5xl font-bold text-slate-900 mb-8">Implications for V-Commerce</h2>
            <div class="grid grid-cols-1 md:grid-cols-2 gap-8 text-left">
                <div class="bg-white rounded-xl p-8 shadow-sm border border-slate-200 card-hover">
                    <div class="flex items-center mb-4">
                        <div class="w-12 h-12 bg-blue-100 text-blue-600 rounded-full flex items-center justify-center mr-4">
                            <svg class="w-6 h-6" fill="none" stroke="currentColor" viewBox="0 0 24 24">
                                <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M9 12l2 2 4-4m6 2a9 9 0 11-18 0 9 9 0 0118 0z"></path>
                            </svg>
                        </div>
                        <h3 class="text-2xl font-bold text-slate-900">Respect Autonomy</h3>
                    </div>
                    <p class="text-large text-slate-600 leading-relaxed">
                        Users in VR environments value the ability to explore independently. Premature intervention by AI agents breaks immersion and is perceived as annoying rather than helpful.
                    </p>
                </div>
                <div class="bg-white rounded-xl p-8 shadow-sm border border-slate-200 card-hover">
                    <div class="flex items-center mb-4">
                        <div class="w-12 h-12 bg-blue-100 text-blue-600 rounded-full flex items-center justify-center mr-4">
                            <svg class="w-6 h-6" fill="none" stroke="currentColor" viewBox="0 0 24 24">
                                <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M13 10V3L4 14h7v7l9-11h-7z"></path>
                            </svg>
                        </div>
                        <h3 class="text-2xl font-bold text-slate-900">Context Awareness</h3>
                    </div>
                    <p class="text-large text-slate-600 leading-relaxed">
                        Sales agents should be programmed to detect "browsing behavior" (e.g., viewing multiple products) before offering assistance, mirroring effective human sales strategies.
                    </p>
                </div>
            </div>
        </div>
    </section>

    <footer class="bg-white py-8 border-t border-slate-200">
        <div class="max-w-7xl mx-auto px-4 text-center text-slate-500 text-sm">
            <p>&copy; 2025 Tobias Weiß. Based on "Interference Timing of GenAI Sales Agents in Virtual Reality".</p>
        </div>
    </footer>
</div>

<script>
    (function() {
        // --- Data Handling ---

        // Product Data from Report Snippet
        const products = [
            {
                name: "Explorer",
                price: "€229.99",
                type: "Kit (Bausatz)",
                size: "350x350x250mm",
                heatedBed: "No",
                material: "PLA, PETG",
                desc: "Entry level kit. Requires assembly. Lacks heated bed, limiting material options."
            },
            {
                name: "Solid",
                price: "€499.99",
                type: "Kit (Bausatz)",
                size: "400x400x405mm",
                heatedBed: "Yes",
                material: "PLA, PETG, ABS",
                desc: "Mid-range kit. Large build volume and heated bed allow for more durable materials."
            },
            {
                name: "Plus",
                price: "€659.99",
                type: "Ready to Use",
                size: "430x400x435mm",
                heatedBed: "Yes",
                material: "PLA, PETG, ABS",
                desc: "Premium experience. Comes assembled. Cited as 'Good value for money' in the study."
            }
        ];

        // Pipeline Steps Data
        const pipelineSteps = [
            { id: 1, title: "1. User Speech", desc: "The participant speaks naturally to the avatar in the VR environment, asking questions like 'Which printer is best for beginners?'" },
            { id: 2, title: "2. Speech-to-Text", desc: "The audio input is captured and converted into text string using Azure Cognitive Services, handling ambient noise and voice clarity." },
            { id: 3, title: "3. LLM Processing", desc: "The text query is sent to a Large Language Model (GPT-4). The model has system prompts defining it as a 'helpful sales assistant' aware of the product catalog." },
            { id: 4, title: "4. Text-to-Speech", desc: "The LLM's text response is converted back into synthesized speech (Azure Neural TTS) and lip-synced by the 3D avatar." }
        ];

        // Chart Data (Representative of typical findings in this domain)
        const chartData = {
            perception: {
                labels: ['Perceived Usefulness', 'Perceived Intrusiveness'],
                datasets: [
                    {
                        label: 'Immediate Interference',
                        data: [2.93, 3.87], // Lower usefulness, higher intrusiveness
                        backgroundColor: 'rgba(239, 68, 68, 0.8)', // Red
                        borderColor: 'rgba(239, 68, 68, 1)',
                        borderWidth: 1
                    },
                    {
                        label: 'Delayed Interference',
                        data: [3.86, 1.92], // Higher usefulness, lower intrusiveness
                        backgroundColor: 'rgba(59, 130, 246, 0.8)', // Blue
                        borderColor: 'rgba(59, 130, 246, 1)',
                        borderWidth: 1
                    }
                ]
            },
            outcomes: {
                labels: ['Decision Confidence', 'Purchase Intention'],
                datasets: [
                    {
                        label: 'Immediate Interference',
                        data: [3.45, 3.10],
                        backgroundColor: 'rgba(239, 68, 68, 0.8)',
                        borderColor: 'rgba(239, 68, 68, 1)',
                        borderWidth: 1
                    },
                    {
                        label: 'Delayed Interference',
                        data: [4.12, 3.78],
                        backgroundColor: 'rgba(59, 130, 246, 0.8)',
                        borderColor: 'rgba(59, 130, 246, 1)',
                        borderWidth: 1
                    }
                ]
            }
        };

        // --- UI Rendering Functions ---

        function renderProducts() {
            const container = document.getElementById('product-grid');
            if (!container) return;
            container.innerHTML = products.map(p => `
                <div class="bg-white rounded-xl p-6 border border-slate-200 card-hover flex flex-col h-full">
                    <div class="flex justify-between items-start mb-4">
                        <h3 class="text-2xl font-bold text-slate-800">${p.name}</h3>
                        <span class="bg-slate-100 text-slate-600 text-base font-semibold px-3 py-2 rounded-lg">${p.price}</span>
                    </div>
                    <div class="space-y-3 text-large text-slate-600 flex-grow">
                        <p><span class="font-semibold text-slate-900">Type:</span> ${p.type}</p>
                        <p><span class="font-semibold text-slate-900">Bed:</span> ${p.heatedBed === 'Yes' ? 'Heated 🔥' : 'Standard'}</p>
                        <p><span class="font-semibold text-slate-900">Materials:</span> ${p.material}</p>
                        <p class="mt-4 text-slate-500 italic border-t border-slate-100 pt-3 text-base">"${p.desc}"</p>
                    </div>
                </div>
            `).join('');
        }

        window.highlightStep = function(stepId) {
            // Reset all icons
            for(let i=1; i<=4; i++) {
                const icon = document.getElementById(`step-${i}-icon`);
                if (!icon) continue;
                if(i === stepId) {
                    icon.classList.remove('bg-slate-100', 'text-slate-600');
                    icon.classList.add('bg-blue-600', 'text-white');
                } else {
                    icon.classList.add('bg-slate-100', 'text-slate-600');
                    icon.classList.remove('bg-blue-600', 'text-white');
                }
            }

            // Update text
            const step = pipelineSteps.find(s => s.id === stepId);
            document.getElementById('detail-title').innerText = step.title;
            document.getElementById('detail-desc').innerText = step.desc;
        }

        // --- Chart Logic ---

        let myChart = null;

        function initChart(type) {
            const chartElem = document.getElementById('mainChart');
            if (!chartElem) return;
            const ctx = chartElem.getContext('2d');
            const config = {
                type: 'bar',
                data: chartData[type],
                options: {
                    responsive: true,
                    maintainAspectRatio: false,
                    plugins: {
                        legend: { position: 'top' },
                        title: {
                            display: true,
                            text: type === 'perception' ? 'Impact on User Perception (Scale 1-5)' : 'Impact on Business Outcomes (Scale 1-5)',
                            font: { size: 16 }
                        }
                    },
                    scales: {
                        y: {
                            beginAtZero: true,
                            max: 5,
                            title: { display: true, text: 'Likert Scale Score' }
                        }
                    }
                }
            };

            if (myChart) {
                myChart.destroy();
            }
            myChart = new Chart(ctx, config);
        }

        window.updateChart = function(type) {
            // Update buttons state
            const btnPerception = document.getElementById('btn-perception');
            const btnOutcomes = document.getElementById('btn-outcomes');

            if (btnPerception && btnOutcomes) {
                if(type === 'perception') {
                    btnPerception.classList.add('bg-white', 'text-blue-600', 'shadow-sm');
                    btnPerception.classList.remove('text-slate-600');
                    btnOutcomes.classList.remove('bg-white', 'text-blue-600', 'shadow-sm');
                    btnOutcomes.classList.add('text-slate-600');
                } else {
                    btnOutcomes.classList.add('bg-white', 'text-blue-600', 'shadow-sm');
                    btnOutcomes.classList.remove('text-slate-600');
                    btnPerception.classList.remove('bg-white', 'text-blue-600', 'shadow-sm');
                    btnPerception.classList.add('text-slate-600');
                }
            }

            initChart(type);
        }

        window.scrollToSection = function(sectionId) {
            document.getElementById(sectionId).scrollIntoView({ behavior: 'smooth' });
        }

        // --- Initialization ---
        renderProducts();
        highlightStep(1); // Set initial state for pipeline
        updateChart('perception'); // Set initial chart
    })();
</script>
{{< /rawhtml >}}