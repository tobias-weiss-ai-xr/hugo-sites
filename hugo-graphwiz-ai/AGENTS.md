# AGENTS.md

Repository conventions for agentic coding assistants working in this Hugo-based site.

## Project Overview
- **Framework**: Hugo v0.57.0 (extended) static site generator
- **Theme**: Custom theme "tobi-goa" (no external theme used)
- **3D Visualization**: Three.js with CSS3DRenderer for interactive periodic table
- **Deployment**: Docker-based Alpine Linux container
- **Build Artifact**: Static site generated in `public/` directory

## Build Commands

```bash
# Build complete site (from myhugoapp directory)
cd myhugoapp && hugo

# Serve locally with live reload
cd myhugoapp && hugo server -w --bind=0.0.0.0

# Via Docker
docker build -t hugo-graphwiz-ai .
docker run -p 1313:1313 -v $(pwd):/src -u hugo hugo-graphwiz-ai hugo server -w --bind=0.0.0.0
```

## Testing Commands

```bash
# Run full test suite
cd myhugoapp && npm test

# Run specific test category
npm run test:contrast     # Accessibility contrast tests
npm run test:layout        # Layout/centering tests
npm run test:html          # HTML validation
npm run test:js            # JavaScript unit tests
npm run test:seo           # SEO checks
npm run test:performance   # Performance tests
npm run test:pa11y         # Pa11y accessibility tests

# Quick tests (development)
npm run test:quick        # contrast + layout + js tests
npm run test:all          # All tests including pa11y
```

## Code Style Guidelines

### JavaScript
- **Module Format**: ES6 modules (`import ... from ...`)
- **Three.js Usage**: Import from `/js/three.module.js`, not npm package
- **Variable Naming**: `camelCase` for variables and functions
- **Constants**: `UPPER_SNAKE_CASE` for constants
- **Indentation**: 4 spaces (not tabs)
- **Semicolons**: Required
- **No Linting**: No ESLint/Prettier configured - follow existing patterns
- **Console Logging**: Limit to 5 console.log statements per file (tests enforce)

### HTML / Hugo Templates
- **Templates**: Use Go template syntax `{{ .variable }}`
- **Raw HTML**: Goldmark unsafe mode enabled - raw HTML allowed
- **BaseURL**: `https://graphwiz.ai/` (trailing slash)
- **Content Directory**: `content/`
- **Layout Directory**: `layouts/`
- **Publish Directory**: `public/`

### CSS
- **Location**: `static/css/` for global styles
- **Naming**: `kebab-case` for CSS files
- **Colors**: Use RGBA for transparency support in 3D elements
- **Responsive**: Mobile breakpoint at 768px width

## File Structure Patterns

```
myhugoapp/
├── config.toml              # Hugo configuration
├── content/                 # Markdown content
├── layouts/                 # Custom Hugo templates
├── static/                  # Static assets (served directly)
│   ├── css/                # Stylesheets
│   ├── js/                 # JavaScript modules
│   │   ├── three/          # Three.js library files
│   │   └── addons/         # Three.js addons (CSS3DRenderer, TWEEN, etc.)
│   └── images/             # Images and favicons
├── themes/
│   └── tobi-goa/          # Custom theme
├── tests/                   # Test suite
│   ├── accessibility/        # Contrast tests
│   ├── layout/             # Layout tests
│   ├── html/               # HTML validation
│   ├── javascript/          # JS unit tests
│   ├── seo/                # SEO checks
│   └── performance/         # Performance tests
└── public/                  # Generated site (build output)
```

## JavaScript Module Conventions

### Three.js Integration
```javascript
import * as THREE from '/js/three.module.js';
import { TrackballControls } from '/js/addons/TrackballControls.js';
import { CSS3DRenderer, CSS3DObject } from '/js/addons/CSS3DRenderer.js';
import TWEEN from '/js/addons/tween.module.js';
```

### Animation Pattern
```javascript
function animate() {
    requestAnimationFrame(animate);
    TWEEN.update();
    controls.update();
}
```

### Event Listeners
- Use `addEventListener` for DOM events
- Wait for `DOMContentLoaded` before DOM manipulation
- Handle window resize to update Three.js camera/renderer

## Testing Patterns

### Custom Test Framework
Tests use custom Node.js test runner with ANSI color output:
- **assert(condition, message)**: Boolean assertion
- **assertEqual(actual, expected, message)**: Value comparison
- **ANSI colors**: Green (✓), Red (✗), Yellow (⚠)

### Test Categories
1. **Accessibility**: Contrast ratios (WCAG AA/AAA)
2. **Layout**: Element positioning and centering
3. **HTML**: Markup validation
4. **JavaScript**: Function presence, imports, syntax
5. **SEO**: Meta tags, semantic HTML, alt attributes
6. **Performance**: Load times, asset sizes

## Error Handling

### JavaScript
- Use try/catch for async operations
- Validate file existence with `fs.existsSync()`
- Graceful degradation: Skip tests if files not found

### Hugo
- Goldmark renderer allows raw HTML (unsafe mode enabled)
- No error suppression in templates - Hugo will fail fast

## Dependencies

### Runtime
- `three`: ^0.182.0 - 3D graphics library

### Dev Dependencies
- `pa11y`: ^9.0.1 - Automated accessibility testing
- `pa11y-ci`: ^4.0.1 - CI integration for pa11y

## Deployment Notes

- **Container**: Alpine Linux with Hugo Extended v0.57.0
- **User**: Non-root user `hugo` (UID 1000)
- **Port**: 1313 (Hugo default)
- **Build Output**: `public/` directory (mounted to web server)
- **Minification**: Uses `minify` tool for asset optimization

## Dark Mode Implementation
- Default: Dark mode enabled
- Persistence: `localStorage` with key `theme`
- Detection: System preference via `getPreferredTheme()`
- Toggle: `data-theme` attribute on `<html>` element
- Button: `#theme-toggle` element

## Three.js 3D Scenes
- **Renderer**: CSS3DRenderer for HTML-based 3D
- **Camera**: PerspectiveCamera with TrackballControls
- **Controls**: TrackballControls for orbit/pan/zoom
- **Animations**: TWEEN library for smooth transitions
- **Responsive**: Camera aspect ratio and renderer size update on resize
