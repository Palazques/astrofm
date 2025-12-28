import React, { useState, useEffect } from 'react';

const CosmicWaveLoader = () => {
    const [loadingProgress, setLoadingProgress] = useState(0);
    const [loadingMessage, setLoadingMessage] = useState(0);

    const loadingMessages = [
        "Reading your stars...",
        "Translating frequencies...",
        "Mapping cosmic rhythms...",
        "Aligning sound waves...",
        "Curating your vibe...",
    ];

    useEffect(() => {
        const interval = setInterval(() => {
            setLoadingProgress(prev => {
                if (prev >= 100) return 0;
                return prev + 1;
            });
        }, 50);

        const messageInterval = setInterval(() => {
            setLoadingMessage(prev => (prev + 1) % loadingMessages.length);
        }, 2500);

        return () => {
            clearInterval(interval);
            clearInterval(messageInterval);
        };
    }, []);

    return (
        <div style={{
            display: 'flex',
            flexDirection: 'column',
            alignItems: 'center',
            justifyContent: 'center',
            padding: '40px',
            fontFamily: "'Syne', sans-serif",
        }}>
            <style>{`
        @keyframes orbit1 {
          0% { transform: rotate(0deg) translateX(50px) rotate(0deg); }
          100% { transform: rotate(360deg) translateX(50px) rotate(-360deg); }
        }
        @keyframes orbit2 {
          0% { transform: rotate(120deg) translateX(70px) rotate(-120deg); }
          100% { transform: rotate(480deg) translateX(70px) rotate(-480deg); }
        }
        @keyframes orbit3 {
          0% { transform: rotate(240deg) translateX(90px) rotate(-240deg); }
          100% { transform: rotate(600deg) translateX(90px) rotate(-600deg); }
        }
        @keyframes notePulse {
          0%, 100% { transform: scale(1); }
          50% { transform: scale(1.4); }
        }
        @keyframes fadeInOut {
          0%, 100% { opacity: 0.5; }
          50% { opacity: 1; }
        }
      `}</style>

            <div style={{
                width: '200px',
                height: '150px',
                position: 'relative',
                marginBottom: '32px',
                display: 'flex',
                alignItems: 'center',
                justifyContent: 'center',
            }}>
                {/* Wave SVG */}
                <svg width="200" height="100" viewBox="0 0 200 100" style={{ position: 'absolute' }}>
                    <defs>
                        <linearGradient id="waveGrad1" x1="0%" y1="0%" x2="100%" y2="0%">
                            <stop offset="0%" stopColor="#7D67FE" />
                            <stop offset="50%" stopColor="#FF59D0" />
                            <stop offset="100%" stopColor="#FAFF0E" />
                        </linearGradient>
                        <linearGradient id="waveGrad2" x1="0%" y1="0%" x2="100%" y2="0%">
                            <stop offset="0%" stopColor="#FF59D0" />
                            <stop offset="50%" stopColor="#00D4AA" />
                            <stop offset="100%" stopColor="#7D67FE" />
                        </linearGradient>
                    </defs>

                    {/* Wave 1 */}
                    <path
                        d="M0,50 Q25,10 50,50 T100,50 T150,50 T200,50"
                        fill="none"
                        stroke="url(#waveGrad1)"
                        strokeWidth="4"
                        strokeLinecap="round"
                        opacity="0.8"
                    >
                        <animate
                            attributeName="d"
                            dur="1.5s"
                            repeatCount="indefinite"
                            values="
                M0,50 Q25,10 50,50 T100,50 T150,50 T200,50;
                M0,50 Q25,90 50,50 T100,50 T150,50 T200,50;
                M0,50 Q25,10 50,50 T100,50 T150,50 T200,50
              "
                        />
                    </path>

                    {/* Wave 2 */}
                    <path
                        d="M0,50 Q25,70 50,50 T100,50 T150,50 T200,50"
                        fill="none"
                        stroke="url(#waveGrad2)"
                        strokeWidth="3"
                        strokeLinecap="round"
                        opacity="0.5"
                    >
                        <animate
                            attributeName="d"
                            dur="2s"
                            repeatCount="indefinite"
                            values="
                M0,50 Q25,85 50,50 T100,50 T150,50 T200,50;
                M0,50 Q25,15 50,50 T100,50 T150,50 T200,50;
                M0,50 Q25,85 50,50 T100,50 T150,50 T200,50
              "
                        />
                    </path>
                </svg>

                {/* Center note */}
                <div style={{
                    width: '60px',
                    height: '60px',
                    borderRadius: '50%',
                    background: 'linear-gradient(135deg, #FAFF0E 0%, #FF59D0 100%)',
                    display: 'flex',
                    alignItems: 'center',
                    justifyContent: 'center',
                    boxShadow: '0 0 30px #FAFF0E40',
                    animation: 'notePulse 1s ease-in-out infinite',
                    zIndex: 2,
                }}>
                    <span style={{ fontSize: '24px', color: '#0A0A0F' }}>♪</span>
                </div>

                {/* Orbiting music notes */}
                {[0, 1, 2].map((i) => (
                    <div
                        key={i}
                        style={{
                            position: 'absolute',
                            animation: `orbit${i + 1} ${3 + i}s linear infinite`,
                        }}
                    >
                        <span style={{
                            fontSize: ['18px', '16px', '14px'][i],
                            color: ['#7D67FE', '#FF59D0', '#00D4AA'][i],
                            filter: `drop-shadow(0 0 8px ${['#7D67FE', '#FF59D0', '#00D4AA'][i]})`,
                        }}>
                            {['♪', '♫', '♪'][i]}
                        </span>
                    </div>
                ))}
            </div>

            {/* Loading message */}
            <p style={{
                fontSize: '14px',
                color: '#FAFF0E',
                fontWeight: 600,
                marginBottom: '8px',
                animation: 'fadeInOut 2.5s ease-in-out infinite',
            }}>{loadingMessages[loadingMessage]}</p>

            {/* Progress bar */}
            <div style={{
                width: '150px',
                height: '4px',
                background: 'rgba(255,255,255,0.1)',
                borderRadius: '2px',
                overflow: 'hidden',
            }}>
                <div style={{
                    width: `${loadingProgress}%`,
                    height: '100%',
                    background: 'linear-gradient(90deg, #FAFF0E, #FF59D0, #7D67FE)',
                    borderRadius: '2px',
                    transition: 'width 0.05s linear',
                }} />
            </div>
        </div>
    );
};

export default CosmicWaveLoader;