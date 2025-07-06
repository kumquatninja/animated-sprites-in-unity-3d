using UnityEngine;
using UnityEngine.Assertions;
using UnityEngine.EventSystems;
using UnityEngine.UI;

namespace HeartHeist.UI
{
    public class SpriteSheetAnimator : MonoBehaviour
    {
        private Image _image;
        public int TotalFramesCount = 16;
        public float FrameRate = 12f;
        private Material _runtimeMaterial;
        [SerializeField] private bool _playOnce = false;

        private float _timer = 0f;
        [SerializeField] private int _currentFrame = 0;
        private bool _isPlaying = true;

        private void Start()
        {
            _image = GetComponent<Image>();
            Debug.Assert(_image != null);
            _runtimeMaterial = new Material(_image.material);
            _image.material = _runtimeMaterial;
        }

        public void Play()
        {
            _image.enabled = true;
            _currentFrame = 0;
            _runtimeMaterial.SetFloat("_Frame", _currentFrame);
            _timer = 0f;
            _isPlaying = true;
        }

        public void Reset()
        {
            _image.enabled = false;
        }

        private void Update()
        {
            if (!_isPlaying)
            {
                return;
            }

            float frameDuration = 1f / FrameRate;
            _timer += Time.deltaTime;

            if (_timer < frameDuration)
            {
                return;
            }

            _currentFrame = (_currentFrame + 1) % TotalFramesCount;
            _runtimeMaterial.SetFloat("_Frame", _currentFrame);

            _timer -= frameDuration;

            if (_playOnce && (_currentFrame == TotalFramesCount - 1))
            {
                _isPlaying = false;
            }
        }
    }
}
