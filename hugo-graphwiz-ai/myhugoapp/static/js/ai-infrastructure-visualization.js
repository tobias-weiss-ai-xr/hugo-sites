/**
 * AI Infrastructure 3D Visualization
 * Shows Docker, Traefik, Ollama architecture in interactive 3D
 */

import * as THREE from '/js/three.module.js';
import { TrackballControls } from '/js/addons/TrackballControls.js';
import { CSS3DRenderer, CSS3DObject } from '/js/addons/CSS3DRenderer.js';
import TWEEN from '/js/addons/tween.module.js';

// Scene setup
const container = document.createElement('div');
container.style.position = 'relative';
container.style.width = '100%';
container.style.height = '600px';
container.style.marginBottom = '20px';
document.currentScript.parentNode.appendChild(container);

const scene = new THREE.Scene();
scene.background = new THREE.Color(0x1a1a2e); // Dark background

// Camera
const camera = new THREE.PerspectiveCamera(
    50,
    container.clientWidth / container.clientHeight,
    0.1,
    1000
);
camera.position.set(20, 15, 20);
camera.lookAt(0, 0, 0);

// CSS3D Renderer (for text labels)
const renderer = new CSS3DRenderer();
renderer.setSize(container.clientWidth, container.clientHeight);
container.appendChild(renderer.domElement);

// WebGL Renderer (for 3D elements)
const webglRenderer = new THREE.WebGLRenderer({ antialias: true });
webglRenderer.setSize(container.clientWidth, container.clientHeight);
webglRenderer.domElement.style.position = 'absolute';
webglRenderer.domElement.style.top = '0';
webglRenderer.domElement.style.left = '0';
container.appendChild(webglRenderer.domElement);

// Controls
const controls = new TrackballControls(camera, container);

// Lights
const ambientLight = new THREE.AmbientLight(0xffffff, 0.6);
scene.add(ambientLight);

const directionalLight = new THREE.DirectionalLight(0xffffff, 0.8);
directionalLight.position.set(10, 20, 10);
scene.add(directionalLight);

// Group for all objects
const infrastructureGroup = new THREE.Group();
scene.add(infrastructureGroup);

// Create components
function createBox(color, width, height, depth, position, label) {
    const geometry = new THREE.BoxGeometry(width, height, depth);
    const material = new THREE.MeshPhongMaterial({ color: color });
    const mesh = new THREE.Mesh(geometry, material);
    mesh.position.set(...position);
    infrastructureGroup.add(mesh);

    // Add label
    const labelDiv = document.createElement('div');
    labelDiv.className = 'ai-infrastructure-label';
    labelDiv.textContent = label;
    labelDiv.style.color = '#ffffff';
    labelDiv.style.fontSize = '14px';
    labelDiv.style.fontWeight = 'bold';
    labelDiv.style.textShadow = '0 0 4px rgba(0,0,0,0.8)';
    labelDiv.style.pointerEvents = 'none';

    const labelObject = new CSS3DObject(labelDiv);
    labelObject.position.set(position[0], position[1] + height/2 + 1, position[2]);
    renderer.scene.add(labelObject);

    return mesh;
}

// Create architecture components
// Traefik (Load Balancer) - Center, Blue
const traefik = createBox(0x2196f3, 6, 4, 6, [0, 0, 0], 'Traefik\n(Load Balancer)');

// Authelia (Authentication) - Front Left, Green
const authelia = createBox(0x4ade80, 4, 3, 4, [-8, 0, 0], 'Authelia\n(2FA Auth)');

// CrowdSec (Security) - Front Right, Orange
const crowdsec = createBox(0xff7f50, 4, 3, 4, [8, 0, 0], 'CrowdSec\n(Firewall)');

// Ollama (LLM Engine) - Back Center, Purple
const ollama = createBox(0x9b59b6, 5, 5, 5, [0, -8, 0], 'Ollama\n(LLM Engine)');

// Vector DB (Qdrant) - Back Left, Teal
const qdrant = createBox(0x00bfa5, 4, 4, 4, [-8, -8, 0], 'Qdrant\n(Vector DB)');

// RAG Chatbot - Back Right, Pink
const ragbot = createBox(0xff69b4, 4, 4, 4, [8, -8, 0], 'RAG Chatbot');

// Create connections (lines)
function createConnection(from, to, color = 0x666666) {
    const material = new THREE.LineBasicMaterial({ color: color, linewidth: 2 });
    const points = [
        new THREE.Vector3(...from),
        new THREE.Vector3(...to)
    ];
    const geometry = new THREE.BufferGeometry().setFromPoints(points);
    const line = new THREE.Line(geometry, material);
    infrastructureGroup.add(line);
}

// Connections from Traefik
createConnection([0, 0, 3], [0, 0, 0], 0x2196f3); // Self-connection
createConnection([0, 0, -2], [-8, 0, -2]); // To Authelia
createConnection([0, 0, -2], [8, 0, -2]); // To CrowdSec
createConnection([0, 0, -3], [0, -8, -3]); // To Ollama
createConnection([0, 0, -3], [-8, -8, -3]); // To Qdrant
createConnection([0, 0, -3], [8, -8, -3]); // To RAG Chatbot

// Add connection arrows (Cone)
function createArrow(from, to, color = 0xffffff) {
    const direction = new THREE.Vector3(to[0] - from[0], to[1] - from[1], to[2] - from[2]);
    const length = direction.length();
    direction.normalize();

    const geometry = new THREE.ConeGeometry(0.3, 1, 8);
    const material = new THREE.MeshPhongMaterial({ color: color });
    const cone = new THREE.Mesh(geometry, material);

    cone.position.set(
        from[0] + direction.x * (length / 2),
        from[1] + direction.y * (length / 2),
        from[2] + direction.z * (length / 2)
    );

    cone.quaternion.setFromUnitVectors(new THREE.Vector3(0, 1, 0), direction);
    infrastructureGroup.add(cone);
}

// Add arrows for data flow
createArrow([0, 0, 3], [0, 0, 0], 0x00ff00); // Inbound to Traefik
createArrow([0, 0, -3], [0, -8, -3], 0x00bfa5); // To Qdrant
createArrow([0, 0, -3], [8, -8, -3], 0xff69b4); // To RAG Chatbot

// Add grid floor
const gridHelper = new THREE.GridHelper(30, 30, 0x444444, 0x666666);
gridHelper.position.y = -4;
infrastructureGroup.add(gridHelper);

// Animation function
function animate() {
    requestAnimationFrame(animate);
    TWEEN.update();
    controls.update();

    // Subtle rotation for visual interest
    infrastructureGroup.rotation.y += 0.001;

    renderer.render(scene, camera);
    webglRenderer.render(scene, camera);
}

// Initial animation - fade in components
const components = [traefik, authelia, crowdsec, ollama, qdrant, ragbot];
components.forEach((mesh, index) => {
    mesh.scale.set(0, 0, 0);

    new TWEEN.Tween(mesh.scale)
        .to({ x: 1, y: 1, z: 1 }, 1000)
        .easing(TWEEN.Easing.Elastic.Out)
        .delay(index * 200)
        .start();
});

// Handle resize
window.addEventListener('resize', () => {
    const width = container.clientWidth;
    const height = container.clientHeight;

    camera.aspect = width / height;
    camera.updateProjectionMatrix();

    renderer.setSize(width, height);
    webglRenderer.setSize(width, height);
});

// Start animation
animate();

// Add hover interaction for tooltips
const raycaster = new THREE.Raycaster();
const mouse = new THREE.Vector2();

container.addEventListener('mousemove', (event) => {
    const rect = container.getBoundingClientRect();
    mouse.x = ((event.clientX - rect.left) / rect.width) * 2 - 1;
    mouse.y = -((event.clientY - rect.top) / rect.height) * 2 + 1;

    raycaster.setFromCamera(mouse, camera);
    const intersects = raycaster.intersectObjects([traefik, authelia, crowdsec, ollama, qdrant, ragbot]);

    // Reset all boxes
    [traefik, authelia, crowdsec, ollama, qdrant, ragbot].forEach(mesh => {
        mesh.material.emissive.setHex(0x000000);
    });

    if (intersects.length > 0) {
        const hovered = intersects[0].object;
        hovered.material.emissive.setHex(0x333333);
        container.style.cursor = 'pointer';
    } else {
        container.style.cursor = 'default';
    }
});

// Add click interaction for component info
container.addEventListener('click', (event) => {
    const rect = container.getBoundingClientRect();
    mouse.x = ((event.clientX - rect.left) / rect.width) * 2 - 1;
    mouse.y = -((event.clientY - rect.top) / rect.height) * 2 + 1;

    raycaster.setFromCamera(mouse, camera);
    const intersects = raycaster.intersectObjects([traefik, authelia, crowdsec, ollama, qdrant, ragbot]);

    if (intersects.length > 0) {
        const clicked = intersects[0].object;
        const info = getComponentInfo(clicked);
        alert(info);
    }
});

function getComponentInfo(mesh) {
    const descriptions = {
        'Traefik\n(Load Balancer)': {
            name: 'Traefik',
            description: 'Modern reverse proxy and load balancer. Routes incoming requests to appropriate services.',
            link: 'https://goneuland.de/traefik-ab-v3-6-mit-crowdsec-installieren-und-konfigurieren/'
        },
        'Authelia\n(2FA Auth)': {
            name: 'Authelia',
            description: 'Single sign-on and two-factor authentication portal. Protects all AI services.',
            link: 'https://goneuland.de/authelia-zweifaktor-authentifizierung-mittels-docker-compose-und-traefik-installieren/'
        },
        'CrowdSec\n(Firewall)': {
            name: 'CrowdSec',
            description: 'Behavioral intrusion detection system. Blocks malicious requests before they reach services.',
            link: 'https://goneuland.de/crowdsec-firewall-bouncer-installieren/'
        },
        'Ollama\n(LLM Engine)': {
            name: 'Ollama',
            description: 'Self-hosted LLM inference engine. Runs models like Llama 3, Mistral, CodeLlama.',
            link: 'https://ollama.com'
        },
        'Qdrant\n(Vector DB)': {
            name: 'Qdrant',
            description: 'Vector database for storing and retrieving embeddings. Enables fast semantic search.',
            link: 'https://qdrant.tech/'
        },
        'RAG Chatbot': {
            name: 'RAG Chatbot',
            description: 'Retrieval-Augmented Generation chatbot. Combines LLM with your internal knowledge base.',
            link: '/private-ai-chatbots-for-internal-knowledge-management/'
        }
    };

    // Find which component was clicked
    for (const [key, value] of Object.entries(descriptions)) {
        if (mesh.material.color.getHex() === getComponentColor(key)) {
            return `${value.name}\n\n${value.description}\n\nLearn more: ${value.link}`;
        }
    }
    return 'Component not found';
}

function getComponentColor(label) {
    if (label.includes('Traefik')) return 0x2196f3;
    if (label.includes('Authelia')) return 0x4ade80;
    if (label.includes('CrowdSec')) return 0xff7f50;
    if (label.includes('Ollama')) return 0x9b59b6;
    if (label.includes('Qdrant')) return 0x00bfa5;
    if (label.includes('RAG')) return 0xff69b4;
    return 0x666666;
}
