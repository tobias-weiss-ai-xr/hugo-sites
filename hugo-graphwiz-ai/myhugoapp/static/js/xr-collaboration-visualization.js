/**
 * XR Collaboration 3D Visualization
 * Shows BigBlueButton, Hello WebXR, AI Meeting Assistant in 3D
 */

import * as THREE from '/js/three.module.js';
import { TrackballControls } from '/js/addons/TrackballControls.js';
import { CSS3DRenderer, CSS3DObject } from '/js/addons/CSS3DRenderer.js';
import TWEEN from '/js/addons/tween.module.js';

// Scene setup
const container = document.createElement('div');
container.style.position = 'relative';
container.style.width = '100%';
container.style.height = '500px';
container.style.marginBottom = '20px';
document.currentScript.parentNode.appendChild(container);

const scene = new THREE.Scene();
scene.background = new THREE.Color(0x0a0e27); // Purple/dark background

// Camera
const camera = new THREE.PerspectiveCamera(
    60,
    container.clientWidth / container.clientHeight,
    0.1,
    1000
);
camera.position.set(0, 10, 25);
camera.lookAt(0, 0, 0);

// CSS3D Renderer
const renderer = new CSS3DRenderer();
renderer.setSize(container.clientWidth, container.clientHeight);
container.appendChild(renderer.domElement);

// WebGL Renderer for 3D elements
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

// Group for XR objects
const xrGroup = new THREE.Group();
scene.add(xrGroup);

// Create participants (avatars in XR)
function createParticipant(x, y, z, color, name) {
    const geometry = new THREE.CylinderGeometry(1, 1, 3, 8);
    const material = new THREE.MeshPhongMaterial({ color: color });
    const mesh = new THREE.Mesh(geometry, material);
    mesh.position.set(x, y, z);
    xrGroup.add(mesh);

    // Add label
    const labelDiv = document.createElement('div');
    labelDiv.className = 'xr-participant-label';
    labelDiv.textContent = name;
    labelDiv.style.color = '#ffffff';
    labelDiv.style.fontSize = '12px';
    labelDiv.style.fontWeight = 'bold';
    labelDiv.style.textShadow = '0px 2px 4px rgba(0,0,0,0.8)';
    labelDiv.style.padding = '4px 8px';
    labelDiv.style.borderRadius = '4px';
    labelDiv.style.backgroundColor = 'rgba(0,0,0,0.5)';
    labelDiv.style.whiteSpace = 'nowrap';

    const labelObject = new CSS3DObject(labelDiv);
    labelObject.position.set(x, y + 2.5, z);
    renderer.scene.add(labelObject);

    return mesh;
}

// Create BigBlueButton platform (central screen)
function createBBBPlatform() {
    const geometry = new THREE.BoxGeometry(12, 8, 0.5);
    const material = new THREE.MeshPhongMaterial({ 
        color: 0x1e3a8a,
        emissive: 0x1e3a8a,
        emissiveIntensity: 0.3
    });
    const platform = new THREE.Mesh(geometry, material);
    platform.position.set(0, 0, 0);
    xrGroup.add(platform);

    // Add screen content
    const screenDiv = document.createElement('div');
    screenDiv.className = 'bbb-screen';
    screenDiv.innerHTML = `
        <div style="color: white; text-align: center; padding: 20px;">
            <h3 style="margin: 0 0 10px 0;">BigBlueButton</h3>
            <p style="margin: 0; font-size: 11px;">XR Virtual Meeting Platform</p>
            <div style="margin-top: 15px; font-size: 24px;">📹</div>
        </div>
    `;
    screenDiv.style.cssText = `
        width: 600px;
        height: 350px;
        background: linear-gradient(135deg, #1e3a8a 0%, #0f4c81 100%);
        border: 2px solid #2d7cf6;
        border-radius: 8px;
        overflow: hidden;
    `;

    const screenObject = new CSS3DObject(screenDiv);
    screenObject.position.set(0, 2, 0.3);
    renderer.scene.add(screenObject);
}

// Create Hello WebXR portal
function createWebXRPortal(x, y, z) {
    const geometry = new THREE.TorusGeometry(2, 0.5, 16, 100);
    const material = new THREE.MeshPhongMaterial({ 
        color: 0x00ff88,
        emissive: 0x00ff88,
        emissiveIntensity: 0.5,
        transparent: true,
        opacity: 0.8
    });
    const portal = new THREE.Mesh(geometry, material);
    portal.position.set(x, y, z);
    xrGroup.add(portal);

    // Rotate portal animation
    const animate = () => {
        portal.rotation.z += 0.02;
        requestAnimationFrame(animate);
    };
    animate();

    return portal;
}

// Create AI Meeting Assistant (floating orb)
function createAIAssistant(x, y, z) {
    const geometry = new THREE.SphereGeometry(0.8, 32, 32);
    const material = new THREE.MeshPhongMaterial({ 
        color: 0xff6b6b,
        emissive: 0xff6b6b,
        emissiveIntensity: 0.6,
        transparent: true,
        opacity: 0.9
    });
    const orb = new THREE.Mesh(geometry, material);
    orb.position.set(x, y, z);
    xrGroup.add(orb);

    // Add glow effect
    const glowGeometry = new THREE.SphereGeometry(1.2, 32, 32);
    const glowMaterial = new THREE.MeshBasicMaterial({ 
        color: 0xff6b6b,
        transparent: true,
        opacity: 0.2
    });
    const glow = new THREE.Mesh(glowGeometry, glowMaterial);
    orb.add(glow);

    // Pulse animation
    let scale = 1;
    const animate = () => {
        scale = 1 + Math.sin(Date.now() * 0.003) * 0.1;
        orb.scale.set(scale, scale, scale);
        requestAnimationFrame(animate);
    };
    animate();

    return orb;
}

// Create connection lines (participants to BBB)
function createConnection(from, to, color = 0x44aa88) {
    const material = new THREE.LineBasicMaterial({ 
        color: color,
        transparent: true,
        opacity: 0.4
    });
    const points = [
        new THREE.Vector3(...from),
        new THREE.Vector3(...to)
    ];
    const geometry = new THREE.BufferGeometry().setFromPoints(points);
    const line = new THREE.Line(geometry, material);
    xrGroup.add(line);
}

// Build XR meeting scene
// BigBlueButton platform (center)
createBBBPlatform();

// Participants
const participant1 = createParticipant(-6, 0, 3, 0x3498db, 'Alice');
const participant2 = createParticipant(6, 0, 3, 0x4fc3f7, 'Bob');
const participant3 = createParticipant(-4, 0, -5, 0xffd700, 'Charlie');
const participant4 = createParticipant(4, 0, -5, 0x00bcd4, 'Diana');

// Hello WebXR portals (participants entering XR)
createWebXRPortal(-6, 3, 8);
createWebXRPortal(6, 3, 8);

// AI Meeting Assistant (floating in center)
createAIAssistant(0, 6, -4);

// Connection lines (participants to BigBlueButton)
createConnection([-6, 0, 3], [0, 2, 0]);
createConnection([6, 0, 3], [0, 2, 0]);

// Connection lines (participants to XR portals)
createConnection([-6, 0, 3], [-6, 4, 8], 0x00ff88);
createConnection([6, 0, 3], [6, 4, 8], 0x00ff88);

// Add floor grid
const gridHelper = new THREE.GridHelper(20, 20, 0x666666, 0x444444);
gridHelper.position.y = -0.5;
xrGroup.add(gridHelper);

// Animation function
function animate() {
    requestAnimationFrame(animate);
    TWEEN.update();
    controls.update();

    // Subtle camera movement
    const time = Date.now() * 0.0005;
    camera.position.x = Math.sin(time) * 3;
    camera.lookAt(0, 2, 0);

    renderer.render(scene, camera);
    webglRenderer.render(scene, camera);
}

// Fade in elements
const elements = xrGroup.children;
elements.forEach((element, index) => {
    if (element.position) {
        const originalY = element.position.y;
        element.position.y = originalY - 5;
        
        new TWEEN.Tween(element.position)
            .to({ y: originalY }, 1500)
            .easing(TWEEN.Easing.Elastic.Out)
            .delay(index * 100)
            .start();
    }
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

// Interaction
const raycaster = new THREE.Raycaster();
const mouse = new THREE.Vector2();

container.addEventListener('mousemove', (event) => {
    const rect = container.getBoundingClientRect();
    mouse.x = ((event.clientX - rect.left) / rect.width) * 2 - 1;
    mouse.y = -((event.clientY - rect.top) / rect.height) * 2 + 1;

    raycaster.setFromCamera(mouse, camera);
    const intersects = raycaster.intersectObjects([participant1, participant2, participant3, participant4]);

    // Reset all
    [participant1, participant2, participant3, participant4].forEach(mesh => {
        mesh.material.emissive.setHex(mesh.userData.originalColor || 0x000000);
    });

    if (intersects.length > 0) {
        const hovered = intersects[0].object;
        hovered.material.emissive.setHex(0xffffff);
        container.style.cursor = 'pointer';
    } else {
        container.style.cursor = 'default';
    }
});

container.addEventListener('click', (event) => {
    const rect = container.getBoundingClientRect();
    mouse.x = ((event.clientX - rect.left) / rect.width) * 2 - 1;
    mouse.y = -((event.clientY - rect.top) / rect.height) * 2 + 1;

    raycaster.setFromCamera(mouse, camera);
    const intersects = raycaster.intersectObjects([participant1, participant2, participant3, participant4]);

    if (intersects.length > 0) {
        const clicked = intersects[0].object;
        showParticipantInfo(clicked);
    }
});

function showParticipantInfo(mesh) {
    const colors = {
        'Alice': 'Blue participant',
        'Bob': 'Red participant',
        'Charlie': 'Orange participant',
        'Diana': 'Green participant'
    };

    alert(`XR Meeting Participant\n\n${colors[mesh.userData.name] || 'Unknown'}\n\nConnected to BigBlueButton\nEntering XR via Hello WebXR`);
}

// Start animation
animate();
