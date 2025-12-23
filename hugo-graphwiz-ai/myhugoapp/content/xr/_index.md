+++
title = "Extended Reality (XR) Portfolio"
description = "Explore Dr. GraphWiz's work in Virtual Reality (VR), Augmented Reality (AR), and Mixed Reality (MR)."
+++

<!-- Cyber Monkey Video -->
<div class="container intro-section">
  <div class="row">
    <div class="col-md-12">
      <div class="video-wrapper">
        <div class="video-container">
          <video
            id="cyber-monkey-video"
            controls
            autoplay
            muted
            loop
            playsinline
            preload="auto"
            class="intro-video"
          >
            <source src="/videos/cyber_monkey_overlay.mp4" type="video/mp4">
            <p class="video-fallback">
              Your browser doesn't support HTML5 video.
              <a href="/videos/cyber_monkey_overlay.mp4" download="cyber_monkey_overlay.mp4">Download the video</a> instead.
            </p>
          </video>
          <div class="video-loading" id="cyber-monkey-loading">
            <div class="loading-spinner"></div>
          </div>
        </div>
      </div>
    </div>
  </div>
</div>

<script>
document.addEventListener('DOMContentLoaded', function() {
  const cyberMonkeyVideo = document.getElementById('cyber-monkey-video');
  const cyberMonkeyLoading = document.getElementById('cyber-monkey-loading');

  if (cyberMonkeyVideo && cyberMonkeyLoading) {
    cyberMonkeyVideo.addEventListener('canplay', function() {
      cyberMonkeyLoading.style.opacity = '0';
      setTimeout(() => {
        cyberMonkeyLoading.style.display = 'none';
      }, 300);
    });

    cyberMonkeyVideo.addEventListener('error', function() {
      cyberMonkeyLoading.innerHTML = '<p>⚠️ Video failed to load</p>';
      cyberMonkeyLoading.style.background = 'rgba(255, 0, 0, 0.8)';
    });

    setTimeout(() => {
      if (cyberMonkeyLoading.style.display !== 'none') {
        cyberMonkeyLoading.style.opacity = '0';
        setTimeout(() => {
          cyberMonkeyLoading.style.display = 'none';
        }, 300);
      }
    }, 5000);
  }
});
</script>

<style>
/* Video Styles for XR Page */
.video-wrapper {
  position: relative;
  max-width: 800px;
  margin: 0 auto;
  width: 100%;
}

.video-container {
  position: relative;
  width: 100%;
  padding-top: 56.25%;
  border-radius: 15px;
  overflow: hidden;
  box-shadow: 0 15px 35px rgba(0, 0, 0, 0.2);
  background: #000;
}

.intro-video {
  position: absolute;
  top: 0;
  left: 0;
  width: 100%;
  height: 100%;
  display: block;
  object-fit: cover;
  border-radius: 15px;
}

.video-loading {
  position: absolute;
  top: 0;
  left: 0;
  width: 100%;
  height: 100%;
  display: flex;
  flex-direction: column;
  justify-content: center;
  align-items: center;
  background: rgba(0, 0, 0, 0.8);
  color: white;
  z-index: 10;
  transition: opacity 0.3s ease;
}

.loading-spinner {
  width: 40px;
  height: 40px;
  border: 4px solid rgba(255, 255, 255, 0.3);
  border-top: 4px solid #007bff;
  border-radius: 50%;
  animation: spin 1s linear infinite;
  margin-bottom: 10px;
}

@keyframes spin {
  0% { transform: rotate(0deg); }
  100% { transform: rotate(360deg); }
}
</style>

Discover our projects and articles in Extended Reality, covering Virtual Reality (VR), Augmented Reality (AR), and Mixed Reality (MR). These technologies are shaping the future of digital interaction.

## Featured XR Content:

*   [Understanding XR Environments](/xr/extended-reality-environments/)
*   [Dr. GraphWiz Hubs: Your Immersive Virtual Environment](/xr/hubs_instance/)
*   [Hello WebXR: Your Gateway to Immersive Web Experiences](/xr/hello_webxr/)
