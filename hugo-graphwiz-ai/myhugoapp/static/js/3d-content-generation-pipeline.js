/**
 * 3D Content Generation Pipeline Visualization
 * Shows Stable Diffusion → Depth Estimation → 3D Reconstruction
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
scene.background = new THREE.Color(0x1a0e1e); // Green/dark background

// Camera
const camera = new THREE.PerspectiveCamera(
    60,
    container.clientWidth / container.clientHeight,
    0.1,
    1000
);
camera.position.set(0, 8, 20);
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
const ambientLight = new THREE.AmbientLight(0xffffff, 0.5);
scene.add(ambientLight);

const directionalLight = new THREE.DirectionalLight(0xffffff, 0.8);
directionalLight.position.set(10, 20, 10);
scene.add(directionalLight);

// Pipeline stages
const pipelineGroup = new THREE.Group();
scene.add(pipelineGroup);

// Stage 1: Image Generation (Stable Diffusion)
function createImageGenerator(x, y, z) {
    const group = new THREE.Group();
    group.position.set(x, y, z);
    pipelineGroup.add(group);

    // Monitor (screen)
    const screenDiv = document.createElement('div');
    screenDiv.className = 'pipeline-stage';
    screenDiv.innerHTML = `
        <div style="color: white; text-align: center; padding: 15px;">
            <h4 style="margin: 0 0 10px 0; color: #7fff00;">1. Image Generation</h4>
            <p style="margin: 0; font-size: 10px;">Stable Diffusion / Easy Diffusion</p>
            <div style="margin-top: 10px; font-size: 32px;">🎨</div>
        </div>
    `;
    screenDiv.style.cssText = `
        width: 200px;
        height: 150px;
        background: linear-gradient(135deg, #2d3748 0%, #1a2f3a 100%);
        border: 2px solid #7fff00;
        border-radius: 6px;
    `;

    const screenObject = new CSS3DObject(screenDiv);
    screenObject.position.set(0, 1.5, 0);
    renderer.scene.add(screenObject);

    // Camera icon
    const cameraGeometry = new THREE.BoxGeometry(1.5, 1, 1);
    const cameraMaterial = new THREE.MeshPhongMaterial({ color: 0x333333 });
    const cameraMesh = new THREE.Mesh(cameraGeometry, cameraMaterial);
    cameraMesh.position.set(0, -0.8, 1);
    group.add(cameraMesh);

    return group;
}

// Stage 2: Depth Estimation
function createDepthEstimator(x, y, z) {
    const group = new THREE.Group();
    group.position.set(x, y, z);
    pipelineGroup.add(group);

    // Screen
    const screenDiv = document.createElement('div');
    screenDiv.className = 'pipeline-stage';
    screenDiv.innerHTML = `
        <div style="color: white; text-align: center; padding: 15px;">
            <h4 style="margin: 0 0 10px 0; color: #00bfff;">2. Depth Estimation</h4>
            <p style="margin: 0; font-size: 10px;">MiDaS / ZoeDepth</p>
            <div style="margin-top: 10px; font-size: 32px;">📏</div>
        </div>
    `;
    screenDiv.style.cssText = `
        width: 200px;
        height: 150px;
        background: linear-gradient(135deg, #1a237e 0%, #0d2137 100%);
        border: 2px solid #00bfff;
        border-radius: 6px;
    `;

    const screenObject = new CSS3DObject(screenDiv);
    screenObject.position.set(0, 1.5, 0);
    renderer.scene.add(screenObject);

    // Depth layers visualization
    for (let i = 0; i < 5; i++) {
        const geometry = new THREE.BoxGeometry(1.5, 0.15, 1.5);
        const opacity = 0.3 + (i * 0.15);
        const material = new THREE.MeshPhongMaterial({ 
            color: 0x00bfff,
            transparent: true,
            opacity: opacity
        });
        const layer = new THREE.Mesh(geometry, material);
        layer.position.set(0, -0.8 - (i * 0.3), 1 + (i * 0.2));
        group.add(layer);
    }

    return group;
}

// Stage 3: 3D Reconstruction
function createMeshGenerator(x, y, z) {
    const group = new THREE.Group();
    group.position.set(x, y, z);
    pipelineGroup.add(group);

    // Screen
    const screenDiv = document.createElement('div');
    screenDiv.className = 'pipeline-stage';
    screenDiv.innerHTML = `
        <div style="color: white; text-align: center; padding: 15px;">
            <h4 style="margin: 0 0 10px 0; color: #ff6b00;">3. 3D Reconstruction</h4>
            <p style="margin: 0; font-size: 10px;">Open3D / Mesh Generation</p>
            <div style="margin-top: 10px; font-size: 32px;">🔺</div>
        </div>
    `;
    screenDiv.style.cssText = `
        width: 200px;
        height: 150px;
        background: linear-gradient(135deg, #1a5f2e 0%, #134e4a 100%);
        border: 2px solid #ff6b00;
        border-radius: 6px;
    `;

    const screenObject = new CSS3DObject(screenDiv);
    screenObject.position.set(0, 1.5, 0);
    renderer.scene.add(screenObject);

    // Wireframe mesh (symbolizing reconstruction)
    const geometry = new THREE.IcosahedronGeometry(1, 1);
    const material = new THREE.MeshBasicMaterial({ 
        color: 0xff6b00,
        wireframe: true
    });
    const mesh = new THREE.Mesh(geometry, material);
    mesh.position.set(0, -0.8, 0.5);
    mesh.rotation.set(0.5, 0.5, 0);
    group.add(mesh);

    // Solid mesh inside
    const solidGeometry = new THREE.IcosahedronGeometry(0.6, 0);
    const solidMaterial = new THREE.MeshPhongMaterial({ 
        color: 0xff6b00,
        emissive: 0xff6b00,
        emissiveIntensity: 0.3
    });
    const solidMesh = new THREE.Mesh(solidGeometry, solidMaterial);
    solidMesh.position.set(0, -0.6, 0.5);
    group.add(solidMesh);

    return group;
}

// Create pipeline flow arrows
function createFlowArrow(from, to, color = 0xffffff) {
    const direction = new THREE.Vector3(to[0] - from[0], to[1] - from[1], to[2] - from[2]);
    const length = direction.length();
    direction.normalize();

    const geometry = new THREE.ConeGeometry(0.3, 1, 8);
    const material = new THREE.MeshPhongMaterial({ 
        color: color,
        emissive: color,
        emissiveIntensity: 0.5
    });
    const cone = new THREE.Mesh(geometry, material);

    cone.position.set(
        from[0] + direction.x * (length / 2),
        from[1] + direction.y * (length / 2),
        from[2] + direction.z * (length / 2)
    );

    cone.quaternion.setFromUnitVectors(new THREE.Vector3(0, 1, 0), direction);
    pipelineGroup.add(cone);
}

// Build pipeline stages
const stage1 = createImageGenerator(-6, 0, 0);
const stage2 = createDepthEstimator(0, 0, 0);
const stage3 = createMeshGenerator(6, 0, 0);

// Create flow arrows between stages
createFlowArrow([-3, 0, 0], [3, 0, 0], 0x7fff00); // Stage 1 → 2
createFlowArrow([3, 0, 0], [-3, 0, 0], 0x00bfff); // Stage 2 → 3
createFlowArrow([-3, 0, 0], [3, 0, 0], 0xff6b00); // Stage 1 → 3 (direct)

// Add output asset (final 3D model)
function createFinalAsset(x, y, z) {
    const group = new THREE.Group();
    group.position.set(x, y, z);
    pipelineGroup.add(group);

    // Final 3D model (dodecahedron representing asset)
    const geometry = new THREE.DodecahedronGeometry(1.2, 0);
    const material = new THREE.MeshPhongMaterial({ 
        color: 0x00ff88,
        emissive: 0x00ff88,
        emissiveIntensity: 0.4,
        metalness: 0.8,
        roughness: 0.2
    });
    const mesh = new THREE.Mesh(geometry, material);
    mesh.position.set(0, 0, 0);
    group.add(mesh);

    // Glow effect
    const glowGeometry = new THREE.DodecahedronGeometry(1.4, 0);
    const glowMaterial = new THREE.MeshBasicMaterial({ 
        color: 0x00ff88,
        transparent: true,
        opacity: 0.15
    });
    const glowMesh = new THREE.Mesh(glowGeometry, glowMaterial);
    group.add(glowMesh);

    // Spin animation
    const animate = () => {
        mesh.rotation.y += 0.01;
        mesh.rotation.x += 0.005;
        requestAnimationFrame(animate);
    };
    animate();

    return group;
}

const finalAsset = createFinalAsset(0, 2, 5);

// Add base platform
const platformGeometry = new THREE.BoxGeometry(16, 0.2, 8);
const platformMaterial = new THREE.MeshPhongMaterial({ 
    color: 0x222222,
    metalness: 0.9,
    roughness: 0.3
});
const platform = new THREE.Mesh(platformGeometry, platformMaterial);
platform.position.set(0, -0.8, 0);
pipelineGroup.add(platform);

// Add grid
const gridHelper = new THREE.GridHelper(20, 20, 0x444444, 0x666666);
gridHelper.position.y = -0.79;
pipelineGroup.add(gridHelper);

// Animation function
function animate() {
    requestAnimationFrame(animate);
    TWEEN.update();
    controls.update();

    // Subtle rotation of pipeline
    pipelineGroup.rotation.y += 0.002;

    renderer.render(scene, camera);
    webglRenderer.render(scene, camera);
}

// Fade in elements
const elements = [stage1, stage2, stage3, finalAsset];
elements.forEach((element, index) => {
    const originalY = element.position.y;
    element.position.y = originalY - 3;
    
    new TWEEN.Tween(element.position)
        .to({ y: originalY }, 1200)
        .easing(TWEEN.Easing.Elastic.Out)
        .delay(index * 150)
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

// Interaction
const raycaster = new THREE.Raycaster();
const mouse = new THREE.Vector2();

container.addEventListener('mousemove', (event) => {
    const rect = container.getBoundingClientRect();
    mouse.x = ((event.clientX - rect.left) / rect.width) * 2 - 1;
    mouse.y = -((event.clientY - rect.top) / rect.height) * 2 + 1;

    raycaster.setFromCamera(mouse, camera);
    const intersects = raycaster.intersectObjects([stage1, stage2, stage3, finalAsset]);

    // Reset emissive
    [stage1, stage2, stage3].forEach(stage => {
        stage.children.forEach(child => {
            if (child.material) {
                child.material.emissive.setHex(0x000000);
            }
        });
    });

    if (intersects.length > 0) {
        const hovered = intersects[0].object;
        if (hovered.material) {
            hovered.material.emissive.setHex(0xffffff);
        }
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
    const intersects = raycaster.intersectObjects([stage1, stage2, stage3, finalAsset]);

    if (intersects.length > 0) {
        const clicked = intersects[0].object;
        showStageInfo(clicked);
    }
});

function showStageInfo(mesh) {
    const stageInfo = {
        '1. Image Generation': {
            description: 'Generates 2D concept art from text prompts using Stable Diffusion or Easy Diffusion.',
            tech: 'Stable Diffusion, Easy Diffusion',
            output: '512x512 to 1024x1024 images'
        },
        '2. Depth Estimation': {
            description: 'Extracts depth information from 2D images to understand 3D structure.',
            tech: 'MiDaS, ZoeDepth, Marigold',
            output: 'Depth maps (grayscale images)'
        },
        '3. 3D Reconstruction': {
            description: 'Converts depth maps into 3D mesh geometry for use in XR applications.',
            tech: 'Open3D, MeshLab, Instant-NGP',
            output: 'glTF, FBX, OBJ files'
        }
    };

    for (const [key, value] of Object.entries(stageInfo)) {
        if (mesh.parent && mesh.parent.userData && mesh.parent.userData.stage === key) {
            alert(`${key}\n\n${value.description}\n\nTechnology: ${value.tech}\nOutput: ${value.output}`);
            return;
        }
    }
}

// Assign stage metadata
stage1.userData = { stage: '1. Image Generation' };
stage2.userData = { stage: '2. Depth Estimation' };
stage3.userData = { stage: '3. 3D Reconstruction' };
finalAsset.userData = { stage: 'Final 3D Asset' };

// Start animation
animate();
