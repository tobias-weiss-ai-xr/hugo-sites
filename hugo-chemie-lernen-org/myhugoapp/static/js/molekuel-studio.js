import * as THREE from 'three';

// Error handler
window.addEventListener('error', (e) => {
    console.error('Global error:', e.error);
});

window.addEventListener('unhandledrejection', (e) => {
    console.error('Unhandled promise rejection:', e.reason);
});

console.log('Molekülstudio script loaded');

// Globale Variablen (Modul-Scope)
let scene, camera, renderer;
let moleculeGroup = null;
let autoRotate = true;
let isDragging = false;
let previousMousePosition = { x: 0, y: 0 };

// DOM Elemente werden beim Initialisieren gesetzt
let container, canvas, moleculeInput, visualizeBtn, moleculeInfo;
let errorMessage, welcomeScreen, loadingScreen, controlsInfo, autoRotateCheckbox;

// Beispieldaten für Moleküle
const moleculeData = {
    'Wasser': {
        formula: 'H₂O',
        elements: {
            'H': { radius: 0.3, color: '#FFFFFF' },
            'O': { radius: 0.6, color: '#FF0D0D' }
        },
        atoms: [
            { id: 'O-1', element: 'O', position: [0.0, 0.0, 0.0] },
            { id: 'H-1', element: 'H', position: [0.757, 0.586, 0.0] },
            { id: 'H-2', element: 'H', position: [-0.757, 0.586, 0.0] }
        ],
        bonds: [
            { atom1: 'O-1', atom2: 'H-1', type: 'single' },
            { atom1: 'O-1', atom2: 'H-2', type: 'single' }
        ]
    },
    'Methan': {
        formula: 'CH₄',
        elements: {
            'C': { radius: 0.7, color: '#909090' },
            'H': { radius: 0.3, color: '#FFFFFF' }
        },
        atoms: [
            { id: 'C-1', element: 'C', position: [0.0, 0.0, 0.0] },
            { id: 'H-1', element: 'H', position: [0.63, 0.63, 0.63] },
            { id: 'H-2', element: 'H', position: [-0.63, -0.63, 0.63] },
            { id: 'H-3', element: 'H', position: [-0.63, 0.63, -0.63] },
            { id: 'H-4', element: 'H', position: [0.63, -0.63, -0.63] }
        ],
        bonds: [
            { atom1: 'C-1', atom2: 'H-1', type: 'single' },
            { atom1: 'C-1', atom2: 'H-2', type: 'single' },
            { atom1: 'C-1', atom2: 'H-3', type: 'single' },
            { atom1: 'C-1', atom2: 'H-4', type: 'single' }
        ]
    },
    'Ammoniak': {
        formula: 'NH₃',
        elements: {
            'N': { radius: 0.65, color: '#3050F8' },
            'H': { radius: 0.3, color: '#FFFFFF' }
        },
        atoms: [
            { id: 'N-1', element: 'N', position: [0.0, 0.0, 0.0] },
            { id: 'H-1', element: 'H', position: [0.94, 0.0, -0.38] },
            { id: 'H-2', element: 'H', position: [-0.47, 0.81, -0.38] },
            { id: 'H-3', element: 'H', position: [-0.47, -0.81, -0.38] }
        ],
        bonds: [
            { atom1: 'N-1', atom2: 'H-1', type: 'single' },
            { atom1: 'N-1', atom2: 'H-2', type: 'single' },
            { atom1: 'N-1', atom2: 'H-3', type: 'single' }
        ]
    },
    'Kohlendioxid': {
        formula: 'CO₂',
        elements: {
            'C': { radius: 0.7, color: '#909090' },
            'O': { radius: 0.6, color: '#FF0D0D' }
        },
        atoms: [
            { id: 'C-1', element: 'C', position: [0.0, 0.0, 0.0] },
            { id: 'O-1', element: 'O', position: [1.16, 0.0, 0.0] },
            { id: 'O-2', element: 'O', position: [-1.16, 0.0, 0.0] }
        ],
        bonds: [
            { atom1: 'C-1', atom2: 'O-1', type: 'double' },
            { atom1: 'C-1', atom2: 'O-2', type: 'double' }
        ]
    },
    'Ethen': {
        formula: 'C₂H₄',
        elements: {
            'C': { radius: 0.7, color: '#909090' },
            'H': { radius: 0.3, color: '#FFFFFF' }
        },
        atoms: [
            { id: 'C-1', element: 'C', position: [0.67, 0.0, 0.0] },
            { id: 'C-2', element: 'C', position: [-0.67, 0.0, 0.0] },
            { id: 'H-1', element: 'H', position: [1.23, 0.94, 0.0] },
            { id: 'H-2', element: 'H', position: [1.23, -0.94, 0.0] },
            { id: 'H-3', element: 'H', position: [-1.23, 0.94, 0.0] },
            { id: 'H-4', element: 'H', position: [-1.23, -0.94, 0.0] }
        ],
        bonds: [
            { atom1: 'C-1', atom2: 'C-2', type: 'double' },
            { atom1: 'C-1', atom2: 'H-1', type: 'single' },
            { atom1: 'C-1', atom2: 'H-2', type: 'single' },
            { atom1: 'C-2', atom2: 'H-3', type: 'single' },
            { atom1: 'C-2', atom2: 'H-4', type: 'single' }
        ]
    },
    'THC': {
        formula: 'C₂₁H₃₀O₂',
        elements: {
            'C': { radius: 0.7, color: '#909090' },
            'H': { radius: 0.3, color: '#FFFFFF' },
            'O': { radius: 0.6, color: '#FF0D0D' }
        },
        atoms: [
            // Benzene ring (simplified representation)
            { id: 'C-1', element: 'C', position: [0.0, 0.0, 0.0] },
            { id: 'C-2', element: 'C', position: [1.4, 0.0, 0.0] },
            { id: 'C-3', element: 'C', position: [2.1, 1.21, 0.0] },
            { id: 'C-4', element: 'C', position: [1.4, 2.42, 0.0] },
            { id: 'C-5', element: 'C', position: [0.0, 2.42, 0.0] },
            { id: 'C-6', element: 'C', position: [-0.7, 1.21, 0.0] },
            // Pyran ring oxygen
            { id: 'O-1', element: 'O', position: [-0.7, -1.3, 0.0] },
            // Pyran ring carbons
            { id: 'C-7', element: 'C', position: [0.7, -1.3, 0.0] },
            { id: 'C-8', element: 'C', position: [1.4, 0.0, 0.0] },
            // Pentyl side chain (simplified)
            { id: 'C-9', element: 'C', position: [2.8, 0.0, 0.0] },
            { id: 'C-10', element: 'C', position: [3.5, 0.86, 0.0] },
            { id: 'C-11', element: 'C', position: [4.2, 0.0, 0.0] },
            { id: 'C-12', element: 'C', position: [4.9, 0.86, 0.0] },
            { id: 'C-13', element: 'C', position: [5.6, 0.0, 0.0] },
            // Methyl group
            { id: 'C-14', element: 'C', position: [2.1, 1.21, 0.0] },
            // Hydroxyl group
            { id: 'O-2', element: 'O', position: [-1.9, 2.8, 0.0] },
            { id: 'H-1', element: 'H', position: [0.0, -0.94, 0.0] },
            { id: 'H-2', element: 'H', position: [2.34, -0.94, 0.0] },
            { id: 'H-3', element: 'H', position: [2.8, 2.27, 0.0] },
            { id: 'H-4', element: 'H', position: [1.4, 3.36, 0.0] },
            { id: 'H-5', element: 'H', position: [-0.7, 3.36, 0.0] },
            { id: 'H-6', element: 'H', position: [-1.64, 1.21, 0.0] },
            { id: 'H-7', element: 'H', position: [0.7, -2.24, 0.0] },
            { id: 'H-8', element: 'H', position: [3.5, -0.86, 0.0] },
            { id: 'H-9', element: 'H', position: [3.5, 1.72, 0.0] },
            { id: 'H-10', element: 'H', position: [4.2, -0.86, 0.0] },
            { id: 'H-11', element: 'H', position: [4.2, 1.72, 0.0] },
            { id: 'H-12', element: 'H', position: [5.6, -0.94, 0.0] },
            { id: 'H-13', element: 'H', position: [6.3, 0.0, 0.0] },
            { id: 'H-14', element: 'H', position: [2.1, 2.15, 0.0] },
            { id: 'H-15', element: 'H', position: [2.1, 0.27, 0.0] },
            { id: 'H-16', element: 'H', position: [-2.3, 2.8, 0.0] }
        ],
        bonds: [
            // Benzene ring bonds (alternating single/double)
            { atom1: 'C-1', atom2: 'C-2', type: 'double' },
            { atom1: 'C-2', atom2: 'C-3', type: 'single' },
            { atom1: 'C-3', atom2: 'C-4', type: 'double' },
            { atom1: 'C-4', atom2: 'C-5', type: 'single' },
            { atom1: 'C-5', atom2: 'C-6', type: 'double' },
            { atom1: 'C-6', atom2: 'C-1', type: 'single' },
            // Pyran ring
            { atom1: 'C-6', atom2: 'O-1', type: 'single' },
            { atom1: 'O-1', atom2: 'C-7', type: 'single' },
            { atom1: 'C-7', atom2: 'C-8', type: 'single' },
            { atom1: 'C-8', atom2: 'C-2', type: 'single' },
            // Side chain
            { atom1: 'C-9', atom2: 'C-10', type: 'single' },
            { atom1: 'C-10', atom2: 'C-11', type: 'single' },
            { atom1: 'C-11', atom2: 'C-12', type: 'single' },
            { atom1: 'C-12', atom2: 'C-13', type: 'single' },
            // Methyl group
            { atom1: 'C-3', atom2: 'C-14', type: 'single' },
            // Hydroxyl group
            { atom1: 'C-5', atom2: 'O-2', type: 'single' },
            { atom1: 'O-2', atom2: 'H-16', type: 'single' },
            // Hydrogen bonds
            { atom1: 'C-1', atom2: 'H-1', type: 'single' },
            { atom1: 'C-2', atom2: 'H-2', type: 'single' },
            { atom1: 'C-3', atom2: 'H-3', type: 'single' },
            { atom1: 'C-4', atom2: 'H-4', type: 'single' },
            { atom1: 'C-5', atom2: 'H-5', type: 'single' },
            { atom1: 'C-6', atom2: 'H-6', type: 'single' },
            { atom1: 'C-7', atom2: 'H-7', type: 'single' },
            { atom1: 'C-9', atom2: 'H-8', type: 'single' },
            { atom1: 'C-10', atom2: 'H-9', type: 'single' },
            { atom1: 'C-10', atom2: 'H-10', type: 'single' },
            { atom1: 'C-11', atom2: 'H-11', type: 'single' },
            { atom1: 'C-11', atom2: 'H-12', type: 'single' },
            { atom1: 'C-13', atom2: 'H-13', type: 'single' },
            { atom1: 'C-14', atom2: 'H-14', type: 'single' },
            { atom1: 'C-14', atom2: 'H-15', type: 'single' }
        ]
    }
};

function init() {
    console.log('Init function called');

    // Hide loading message
    const loadingMsg = document.getElementById('js-loading');
    if (loadingMsg) {
        loadingMsg.style.display = 'none';
    }

    // DOM Elemente abrufen
    container = document.getElementById('molecule-studio-container');
    canvas = document.getElementById('molecule-canvas');
    moleculeInput = document.getElementById('molecule-input');
    visualizeBtn = document.getElementById('visualize-btn');
    moleculeInfo = document.getElementById('molecule-info');
    errorMessage = document.getElementById('error-message');
    welcomeScreen = document.getElementById('welcome-screen');
    loadingScreen = document.getElementById('loading-screen');
    controlsInfo = document.getElementById('controls-info');
    autoRotateCheckbox = document.getElementById('auto-rotate');

    console.log('DOM elements:', { container, canvas, moleculeInput, visualizeBtn });

    if (!container || !canvas || !moleculeInput || !visualizeBtn) {
        console.error('Ein oder mehrere Elemente nicht gefunden!');
        return;
    }

    console.log('Molekülstudio wird initialisiert...');

    // Scene
    scene = new THREE.Scene();
    scene.background = new THREE.Color(0xf8f9fa);

    // Camera
    camera = new THREE.PerspectiveCamera(
        75,
        container.clientWidth / container.clientHeight || 1,
        0.1,
        1000
    );
    camera.position.z = 10;

    // Renderer
    console.log('Creating WebGL renderer...');
    renderer = new THREE.WebGLRenderer({ canvas: canvas, antialias: true });
    updateRendererSize();
    renderer.shadowMap.enabled = true;
    renderer.shadowMap.type = THREE.PCFSoftShadowMap;
    console.log('Renderer created:', renderer);

    // Lights
    const ambientLight = new THREE.AmbientLight(0x404040, 0.6);
    scene.add(ambientLight);

    const directionalLight = new THREE.DirectionalLight(0xffffff, 0.8);
    directionalLight.position.set(5, 5, 5);
    directionalLight.castShadow = true;
    scene.add(directionalLight);

    // Event Listeners
    setupEventListeners();

    // Setup ResizeObserver for better responsiveness
    setupResizeObserver();

    // Animation
    animate();
}

function updateRendererSize() {
    const width = container.clientWidth;
    const height = container.clientHeight;

    if (width > 0 && height > 0) {
        camera.aspect = width / height;
        camera.updateProjectionMatrix();
        renderer.setSize(width, height, false);
    }
}

function setupResizeObserver() {
    const resizeObserver = new ResizeObserver(() => {
        updateRendererSize();
    });
    resizeObserver.observe(container);
}

function setupEventListeners() {
    console.log('Setting up event listeners...');

    // Visualize button
    visualizeBtn.addEventListener('click', () => {
        console.log('Visualize button clicked');
        const moleculeName = moleculeInput.value.trim();
        if (moleculeName) {
            visualizeMolecule(moleculeName);
        }
    });

    // Enter key
    moleculeInput.addEventListener('keypress', (e) => {
        if (e.key === 'Enter') {
            const moleculeName = moleculeInput.value.trim();
            if (moleculeName) {
                visualizeMolecule(moleculeName);
            }
        }
    });

    // Suggestion chips
    document.querySelectorAll('.suggestion-chip').forEach(chip => {
        chip.addEventListener('click', () => {
            const molecule = chip.dataset.molecule;
            moleculeInput.value = molecule;
            visualizeMolecule(molecule);
        });
    });

    // Auto-rotate toggle
    autoRotateCheckbox.addEventListener('change', (e) => {
        autoRotate = e.target.checked;
    });

    // Mouse controls
    canvas.addEventListener('mousedown', onMouseDown);
    canvas.addEventListener('mouseup', onMouseUp);
    canvas.addEventListener('mousemove', onMouseMove);
    canvas.addEventListener('wheel', onWheel);

    // Window resize
    window.addEventListener('resize', onWindowResize);
}

function onMouseDown(event) {
    isDragging = true;
    previousMousePosition = { x: event.clientX, y: event.clientY };
    autoRotate = false;
    autoRotateCheckbox.checked = false;
}

function onMouseUp() {
    isDragging = false;
}

function onMouseMove(event) {
    if (!isDragging || !moleculeGroup) return;

    const deltaX = event.clientX - previousMousePosition.x;
    const deltaY = event.clientY - previousMousePosition.y;

    moleculeGroup.rotation.y += deltaX * 0.01;
    moleculeGroup.rotation.x += deltaY * 0.01;

    previousMousePosition = { x: event.clientX, y: event.clientY };
}

function onWheel(event) {
    event.preventDefault();
    camera.position.z += event.deltaY * 0.01;
    camera.position.z = Math.max(3, Math.min(30, camera.position.z));
}

function onWindowResize() {
    updateRendererSize();
}

function visualizeMolecule(name) {
    showError('');
    const data = moleculeData[name];

    if (!data) {
        showError(`Molekül "${name}" nicht gefunden. Versuchen Sie: Wasser, Methan, Ammoniak, Kohlendioxid oder Ethen.`);
        return;
    }

    showLoading(true);

    setTimeout(() => {
        renderMolecule(data);
        showMoleculeInfo(data);
        showLoading(false);
        welcomeScreen.style.display = 'none';
        controlsInfo.style.display = 'block';
    }, 500);
}

function renderMolecule(data) {
    // Clear previous molecule
    if (moleculeGroup) {
        scene.remove(moleculeGroup);
    }

    moleculeGroup = new THREE.Group();

    // Create atom map
    const atomMap = new Map();

    // Create atoms
    data.atoms.forEach(atom => {
        const elementInfo = data.elements[atom.element];
        if (!elementInfo) return;

        const color = parseInt(elementInfo.color.replace('#', '0x'));
        const radius = elementInfo.radius;

        const geometry = new THREE.SphereGeometry(radius, 32, 32);
        const material = new THREE.MeshLambertMaterial({ color });
        const sphere = new THREE.Mesh(geometry, material);

        sphere.position.set(...atom.position);
        sphere.castShadow = true;
        sphere.receiveShadow = true;

        moleculeGroup.add(sphere);
        atomMap.set(atom.id, atom);
    });

    // Create bonds
    data.bonds.forEach(bond => {
        const atom1 = atomMap.get(bond.atom1);
        const atom2 = atomMap.get(bond.atom2);

        if (!atom1 || !atom2) return;

        const start = new THREE.Vector3(...atom1.position);
        const end = new THREE.Vector3(...atom2.position);
        const direction = new THREE.Vector3().subVectors(end, start);
        const distance = direction.length();

        if (bond.type === 'single') {
            const cylinder = createBondCylinder(start, end, distance, 0.05);
            moleculeGroup.add(cylinder);
        } else if (bond.type === 'double') {
            const offset = 0.08;
            const perpendicular = calculatePerpendicular(direction);
            const midpoint = new THREE.Vector3().copy(start).add(end).divideScalar(2);

            const cylinder1 = createBondCylinder(
                start.clone().add(perpendicular.clone().multiplyScalar(offset / distance)),
                end.clone().add(perpendicular.clone().multiplyScalar(offset / distance)),
                distance,
                0.04
            );
            const cylinder2 = createBondCylinder(
                start.clone().sub(perpendicular.clone().multiplyScalar(offset / distance)),
                end.clone().sub(perpendicular.clone().multiplyScalar(offset / distance)),
                distance,
                0.04
            );
            moleculeGroup.add(cylinder1);
            moleculeGroup.add(cylinder2);
        }
    });

    scene.add(moleculeGroup);

    // Center and fit to view
    const box = new THREE.Box3().setFromObject(moleculeGroup);
    const center = box.getCenter(new THREE.Vector3());
    const size = box.getSize(new THREE.Vector3());

    moleculeGroup.position.sub(center);

    const maxDim = Math.max(size.x, size.y, size.z);
    const fov = camera.fov * (Math.PI / 180);
    const distance = Math.abs(maxDim / (2 * Math.tan(fov / 2))) * 1.5;

    camera.position.set(0, 0, Math.max(distance, 5));
    camera.lookAt(0, 0, 0);

    // Reset rotation
    moleculeGroup.rotation.set(0, 0, 0);
    autoRotate = true;
    autoRotateCheckbox.checked = true;
}

function createBondCylinder(start, end, distance, radius) {
    const geometry = new THREE.CylinderGeometry(radius, radius, distance, 8);
    const material = new THREE.MeshLambertMaterial({ color: 0x666666 });
    const cylinder = new THREE.Mesh(geometry, material);

    cylinder.position.copy(start).add(end).divideScalar(2);
    cylinder.lookAt(end);
    cylinder.rotateX(Math.PI / 2);

    return cylinder;
}

function calculatePerpendicular(direction) {
    if (Math.abs(direction.y) < 0.9) {
        return new THREE.Vector3(0, 1, 0).cross(direction).normalize();
    } else {
        return new THREE.Vector3(1, 0, 0).cross(direction).normalize();
    }
}

function showLoading(show) {
    loadingScreen.style.display = show ? 'flex' : 'none';
    visualizeBtn.disabled = show;
}

function showMoleculeInfo(data) {
    const info = 'Formel: ' + data.formula + ' • Atome: ' + data.atoms.length + ' • Bindungen: ' + data.bonds.length;
    moleculeInfo.textContent = info;
    moleculeInfo.style.display = 'block';
}

function showError(message) {
    errorMessage.textContent = message;
    errorMessage.style.display = message ? 'block' : 'none';
}

function animate() {
    requestAnimationFrame(animate);

    if (autoRotate && moleculeGroup) {
        moleculeGroup.rotation.y += 0.01;
    }

    renderer.render(scene, camera);
}

console.log('Animation loop function defined');

// Warte bis DOM geladen ist, dann initialisiere
console.log('Document ready state:', document.readyState);

// Warte bis DOM geladen ist, dann initialisiere
if (document.readyState === 'loading') {
    console.log('Waiting for DOMContentLoaded...');
    document.addEventListener('DOMContentLoaded', () => {
        console.log('DOMContentLoaded fired, calling init()');
        init();
    });
} else {
    console.log('DOM already loaded, calling init() immediately');
    init();
}
