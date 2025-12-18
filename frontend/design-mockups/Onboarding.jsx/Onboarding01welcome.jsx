import React, { useState, useEffect } from 'react';

const Onboarding01_Welcome = () => {
    const [showContent, setShowContent] = useState(false);
    const [showButton, setShowButton] = useState(false);

    useEffect(() => {
        setTimeout(() => setShowContent(true), 500);
        setTimeout(() => setShowButton(true), 1500);
    }, []);

    // Generate floating particles
    const particles = Array.from({ length: 20 }, (_, i) => ({
        id: i,
        size: Math.random() * 4 + 2,
        left: Math.random() * 100,
        delay: Math.random() * 5,
        duration: Math.random() * 10 + 10,
        color: ['#FF59D0', '#FAFF0E', '#7D67FE', '#00D4AA'][Math.floor(Math.random() * 4)],
    }));

    return (
        <div style={{
            minHeight: '100vh',
            background: 'linear-gradient(180deg, #0A0A0F 0%, #0D0D15 50%, #12101A 100%)',
            fontFamily: "'Syne', sans-serif",
            color: '#FFFFFF',
            position: 'relative',
            overflow: 'hidden',
            display: 'flex',
            flexDirection: 'column',
        }}>
            <style>{`
        @import url('https://fonts.googleapis.com/css2?family=Syne:wght@400;500;600;700;800&family=Space+Grotesk:wght@300;400;500&display=swap');
        
        @keyframes float {
          0%, 100% { transform: translateY(0); }
          50% { transform: translateY(-20px); }
        }
        
        @keyframes pulse {
          0%, 100% { opacity: 0.6; transform: scale(1); }
          50% { opacity: 1; transform: scale(1.05); }
        }
        
        @keyframes orbGlow {
          0%, 100% { filter: blur(30px) brightness(1); }
          50% { filter: blur(40px) brightness(1.3); }
        }
        
        @keyframes waveform {
          0%, 100% { transform: scaleY(1); }
          50% { transform: scaleY(1.5); }
        }
        
        @keyframes rotateRing {
          0% { transform: rotate(0deg); }
          100% { transform: rotate(360deg); }
        }
        
        @keyframes particleFloat {
          0%, 100% { transform: translateY(0) rotate(0deg); opacity: 0.6; }
          50% { transform: translateY(-100px) rotate(180deg); opacity: 1; }
        }
        
        @keyframes shimmer {
          0% { background-position: -200% center; }
          100% { background-position: 200% center; }
        }
        
        .main-orb {
          position: relative;
          width: 200px;
          height: 200px;
          border-radius: 50%;
          animation: float 6s ease-in-out infinite;
        }
        
        .main-orb::before {
          content: '';
          position: absolute;
          inset: -30px;
          border-radius: 50%;
          background: inherit;
          filter: blur(40px);
          opacity: 0.6;
          animation: orbGlow 4s ease-in-out infinite;
        }
        
        .orb-inner {
          position: absolute;
          inset: 0;
          border-radius: 50%;
          overflow: hidden;
          display: flex;
          align-items: center;
          justify-content: center;
        }
        
        .orb-ring {
          position: absolute;
          border: 1px solid rgba(255, 255, 255, 0.15);
          border-radius: 50%;
        }
        
        .particle {
          position: absolute;
          border-radius: 50%;
          animation: particleFloat ease-in-out infinite;
        }
        
        .cta-button {
          transition: all 0.3s cubic-bezier(0.4, 0, 0.2, 1);
        }
        
        .cta-button:hover {
          transform: translateY(-4px);
          box-shadow: 0 20px 50px rgba(250, 255, 14, 0.4);
        }
      `}</style>

            {/* Floating Particles */}
            {particles.map((particle) => (
                <div
                    key={particle.id}
                    className="particle"
                    style={{
                        width: particle.size,
                        height: particle.size,
                        left: `${particle.left}%`,
                        top: `${Math.random() * 100}%`,
                        background: particle.color,
                        animationDelay: `${particle.delay}s`,
                        animationDuration: `${particle.duration}s`,
                        boxShadow: `0 0 ${particle.size * 2}px ${particle.color}`,
                    }}
                />
            ))}

            {/* Background Gradient Orbs */}
            <div style={{
                position: 'absolute',
                top: '10%',
                left: '-20%',
                width: '500px',
                height: '500px',
                background: 'radial-gradient(circle, rgba(255, 89, 208, 0.15) 0%, transparent 60%)',
                borderRadius: '50%',
                filter: 'blur(60px)',
                animation: 'pulse 8s ease-in-out infinite',
            }} />

            <div style={{
                position: 'absolute',
                bottom: '10%',
                right: '-20%',
                width: '400px',
                height: '400px',
                background: 'radial-gradient(circle, rgba(125, 103, 254, 0.15) 0%, transparent 60%)',
                borderRadius: '50%',
                filter: 'blur(60px)',
                animation: 'pulse 10s ease-in-out infinite 2s',
            }} />

            {/* Main Container */}
            <div style={{
                maxWidth: '420px',
                margin: '0 auto',
                padding: '20px',
                position: 'relative',
                zIndex: 10,
                flex: 1,
                display: 'flex',
                flexDirection: 'column',
                justifyContent: 'center',
                alignItems: 'center',
            }}>

                {/* Main Orb with Waveform */}
                <div
                    className="main-orb"
                    style={{
                        background: 'linear-gradient(135deg, #FF59D0 0%, #7D67FE 50%, #00D4AA 100%)',
                        marginBottom: '48px',
                        opacity: showContent ? 1 : 0,
                        transform: showContent ? 'scale(1)' : 'scale(0.8)',
                        transition: 'all 1s cubic-bezier(0.4, 0, 0.2, 1)',
                    }}
                >
                    {/* Orbital Rings */}
                    <div className="orb-ring" style={{
                        inset: '-25px',
                        animation: 'rotateRing 20s linear infinite',
                    }}>
                        <div style={{
                            position: 'absolute',
                            top: '-4px',
                            left: '50%',
                            width: '8px',
                            height: '8px',
                            borderRadius: '50%',
                            background: '#FAFF0E',
                            boxShadow: '0 0 10px #FAFF0E',
                        }} />
                    </div>
                    <div className="orb-ring" style={{
                        inset: '-45px',
                        animation: 'rotateRing 30s linear infinite reverse',
                    }}>
                        <div style={{
                            position: 'absolute',
                            bottom: '-3px',
                            left: '30%',
                            width: '6px',
                            height: '6px',
                            borderRadius: '50%',
                            background: '#FF59D0',
                            boxShadow: '0 0 8px #FF59D0',
                        }} />
                    </div>
                    <div className="orb-ring" style={{
                        inset: '-65px',
                        animation: 'rotateRing 40s linear infinite',
                    }}>
                        <div style={{
                            position: 'absolute',
                            top: '50%',
                            right: '-3px',
                            width: '5px',
                            height: '5px',
                            borderRadius: '50%',
                            background: '#7D67FE',
                            boxShadow: '0 0 6px #7D67FE',
                        }} />
                    </div>

                    <div className="orb-inner">
                        {/* Custom Waveform SVG */}
                        <svg width="80" height="80" viewBox="0 0 80 80" fill="none">
                            {[0.4, 0.7, 1, 0.8, 0.5, 0.9, 0.6, 0.8, 0.5].map((h, i) => (
                                <rect
                                    key={i}
                                    x={12 + i * 7}
                                    y={40 - (h * 25)}
                                    width="4"
                                    height={h * 50}
                                    rx="2"
                                    fill="rgba(255,255,255,0.85)"
                                    style={{
                                        animation: `waveform ${0.5 + i * 0.1}s ease-in-out infinite`,
                                        animationDelay: `${i * 0.05}s`,
                                        transformOrigin: 'center',
                                    }}
                                />
                            ))}
                        </svg>
                    </div>
                </div>

                {/* Logo and Text */}
                <div style={{
                    textAlign: 'center',
                    opacity: showContent ? 1 : 0,
                    transform: showContent ? 'translateY(0)' : 'translateY(20px)',
                    transition: 'all 0.8s cubic-bezier(0.4, 0, 0.2, 1) 0.3s',
                }}>
                    {/* Logo Icon */}
                    <div style={{
                        display: 'flex',
                        alignItems: 'center',
                        justifyContent: 'center',
                        gap: '12px',
                        marginBottom: '16px',
                    }}>
                        <svg width="40" height="40" viewBox="0 0 40 40" fill="none">
                            <defs>
                                <linearGradient id="logoGrad" x1="0%" y1="0%" x2="100%" y2="100%">
                                    <stop offset="0%" stopColor="#FAFF0E" />
                                    <stop offset="100%" stopColor="#FF59D0" />
                                </linearGradient>
                            </defs>
                            <circle cx="20" cy="20" r="16" stroke="url(#logoGrad)" strokeWidth="2" fill="none" />
                            <ellipse cx="20" cy="20" rx="16" ry="6" stroke="url(#logoGrad)" strokeWidth="1.5" fill="none" transform="rotate(-20 20 20)" />
                            <circle cx="20" cy="20" r="4" fill="url(#logoGrad)" />
                        </svg>

                        <h1 style={{
                            fontSize: '36px',
                            fontWeight: 800,
                            margin: 0,
                            background: 'linear-gradient(135deg, #FFFFFF 0%, #FAFF0E 50%, #FF59D0 100%)',
                            backgroundSize: '200% auto',
                            WebkitBackgroundClip: 'text',
                            WebkitTextFillColor: 'transparent',
                            animation: 'shimmer 4s linear infinite',
                        }}>ASTRO.FM</h1>
                    </div>

                    <p style={{
                        fontSize: '18px',
                        color: 'rgba(255,255,255,0.6)',
                        margin: '0 0 8px 0',
                        fontFamily: "'Space Grotesk', sans-serif",
                    }}>Your Cosmic Sound Profile</p>

                    <p style={{
                        fontSize: '14px',
                        color: 'rgba(255,255,255,0.4)',
                        margin: 0,
                        fontFamily: "'Space Grotesk', sans-serif",
                    }}>Discover the frequency of your birth chart</p>
                </div>

                {/* CTA Button */}
                <div style={{
                    marginTop: '60px',
                    width: '100%',
                    maxWidth: '320px',
                    opacity: showButton ? 1 : 0,
                    transform: showButton ? 'translateY(0)' : 'translateY(20px)',
                    transition: 'all 0.6s cubic-bezier(0.4, 0, 0.2, 1)',
                }}>
                    <button
                        className="cta-button"
                        style={{
                            width: '100%',
                            background: 'linear-gradient(135deg, #FAFF0E 0%, #E5EB0D 100%)',
                            border: 'none',
                            borderRadius: '16px',
                            padding: '18px 32px',
                            fontSize: '16px',
                            fontWeight: 700,
                            fontFamily: "'Syne', sans-serif",
                            color: '#0A0A0F',
                            cursor: 'pointer',
                            boxShadow: '0 10px 40px rgba(250, 255, 14, 0.3)',
                            display: 'flex',
                            alignItems: 'center',
                            justifyContent: 'center',
                            gap: '10px',
                        }}
                    >
                        Begin Your Journey
                        <svg width="20" height="20" viewBox="0 0 24 24" fill="none" stroke="currentColor" strokeWidth="2.5" strokeLinecap="round" strokeLinejoin="round">
                            <path d="M5 12h14M12 5l7 7-7 7" />
                        </svg>
                    </button>

                    <p style={{
                        textAlign: 'center',
                        marginTop: '20px',
                        fontSize: '14px',
                        color: 'rgba(255,255,255,0.4)',
                        fontFamily: "'Space Grotesk', sans-serif",
                    }}>
                        Already have an account? <span style={{ color: '#FAFF0E', cursor: 'pointer' }}>Sign in</span>
                    </p>
                </div>
            </div>
        </div>
    );
};

export default Onboarding01_Welcome;