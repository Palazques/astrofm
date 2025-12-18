import React, { useState, useEffect } from 'react';

const Onboarding10_SoundReady = () => {
    const [showContent, setShowContent] = useState(false);
    const [showStats, setShowStats] = useState(false);
    const [showCelebration, setShowCelebration] = useState(false);

    useEffect(() => {
        setTimeout(() => setShowContent(true), 300);
        setTimeout(() => setShowStats(true), 800);
        setTimeout(() => setShowCelebration(true), 1200);
    }, []);

    const soundStats = [
        {
            label: 'Dominant',
            value: '528 Hz',
            color: '#FAFF0E',
            icon: (
                <svg width="20" height="20" viewBox="0 0 24 24" fill="none">
                    <circle cx="12" cy="12" r="8" stroke="#FAFF0E" strokeWidth="1.5" fill="none" />
                    <circle cx="12" cy="12" r="3" fill="#FAFF0E" />
                </svg>
            )
        },
        {
            label: 'Planets',
            value: '7',
            color: '#FF59D0',
            icon: (
                <svg width="20" height="20" viewBox="0 0 24 24" fill="none">
                    <circle cx="12" cy="12" r="4" stroke="#FF59D0" strokeWidth="1.5" fill="none" />
                    <ellipse cx="12" cy="12" rx="10" ry="4" stroke="#FF59D0" strokeWidth="1" fill="none" transform="rotate(-30 12 12)" />
                </svg>
            )
        },
        {
            label: 'Match',
            value: '94%',
            color: '#00D4AA',
            icon: (
                <svg width="20" height="20" viewBox="0 0 24 24" fill="none">
                    <path d="M20 6L9 17l-5-5" stroke="#00D4AA" strokeWidth="2" strokeLinecap="round" strokeLinejoin="round" />
                </svg>
            )
        },
    ];

    const frequencyBars = [0.4, 0.7, 0.5, 1, 0.8, 0.6, 0.9, 0.5, 0.7, 0.4, 0.8, 0.6];

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
        
        @keyframes pulse { 0%, 100% { opacity: 0.5; transform: scale(1); } 50% { opacity: 0.8; transform: scale(1.05); } }
        @keyframes float { 0%, 100% { transform: translateY(0); } 50% { transform: translateY(-12px); } }
        @keyframes spin { 0% { transform: rotate(0deg); } 100% { transform: rotate(360deg); } }
        @keyframes spinReverse { 0% { transform: rotate(360deg); } 100% { transform: rotate(0deg); } }
        @keyframes waveform { 0%, 100% { transform: scaleY(0.5); } 50% { transform: scaleY(1); } }
        @keyframes orbGlow { 0%, 100% { box-shadow: 0 0 60px rgba(255, 89, 208, 0.4), 0 0 120px rgba(125, 103, 254, 0.2); } 50% { box-shadow: 0 0 80px rgba(255, 89, 208, 0.6), 0 0 160px rgba(125, 103, 254, 0.3); } }
        @keyframes starPulse { 0%, 100% { opacity: 0.6; transform: scale(1); } 50% { opacity: 1; transform: scale(1.1); } }
        @keyframes slideUp { from { transform: translateY(30px); opacity: 0; } to { transform: translateY(0); opacity: 1; } }
        @keyframes popIn { 0% { transform: scale(0); opacity: 0; } 70% { transform: scale(1.1); } 100% { transform: scale(1); opacity: 1; } }
        @keyframes shimmer { 0% { background-position: -200% center; } 100% { background-position: 200% center; } }
        
        .main-orb {
          position: relative; width: 200px; height: 200px; border-radius: 50%;
          animation: float 5s ease-in-out infinite, orbGlow 3s ease-in-out infinite;
        }
        .orb-ring {
          position: absolute; border-radius: 50%;
        }
        .stat-card {
          animation: popIn 0.5s ease forwards;
          opacity: 0;
        }
        .cta-button { transition: all 0.3s cubic-bezier(0.4, 0, 0.2, 1); }
        .cta-button:hover { transform: translateY(-4px); box-shadow: 0 20px 50px rgba(250, 255, 14, 0.4); }
      `}</style>

            {/* Floating Stars Background */}
            {[...Array(12)].map((_, i) => (
                <div key={i} style={{
                    position: 'absolute',
                    top: `${10 + Math.random() * 80}%`,
                    left: `${5 + Math.random() * 90}%`,
                    width: `${4 + Math.random() * 4}px`,
                    height: `${4 + Math.random() * 4}px`,
                    background: ['#FAFF0E', '#FF59D0', '#7D67FE', '#00D4AA'][i % 4],
                    borderRadius: '50%',
                    animation: `starPulse ${2 + Math.random() * 2}s ease-in-out infinite`,
                    animationDelay: `${Math.random() * 2}s`,
                    opacity: 0.6,
                }} />
            ))}

            {/* Background Gradient */}
            <div style={{
                position: 'absolute', top: '15%', left: '50%', transform: 'translateX(-50%)',
                width: '500px', height: '500px',
                background: 'radial-gradient(circle, rgba(0, 212, 170, 0.15) 0%, rgba(125, 103, 254, 0.1) 30%, rgba(255, 89, 208, 0.05) 50%, transparent 70%)',
                borderRadius: '50%', filter: 'blur(60px)', animation: 'pulse 8s ease-in-out infinite',
            }} />

            {/* Main Container */}
            <div style={{
                maxWidth: '420px', margin: '0 auto', padding: '20px',
                position: 'relative', zIndex: 10, flex: 1, display: 'flex', flexDirection: 'column',
            }}>
                {/* Header */}
                <div style={{
                    display: 'flex', justifyContent: 'space-between', alignItems: 'center',
                    padding: '16px 0', opacity: showContent ? 1 : 0, transition: 'opacity 0.5s ease',
                }}>
                    <div style={{ width: '40px' }} />
                    <span style={{ fontSize: '13px', color: 'rgba(255,255,255,0.4)', fontFamily: "'Space Grotesk', sans-serif" }}>Step 9 of 9</span>
                    <div style={{ width: '40px' }} />
                </div>

                {/* Content */}
                <div style={{
                    flex: 1, display: 'flex', flexDirection: 'column', alignItems: 'center', paddingTop: '20px',
                    opacity: showContent ? 1 : 0, transform: showContent ? 'translateY(0)' : 'translateY(20px)',
                    transition: 'all 0.8s cubic-bezier(0.4, 0, 0.2, 1)',
                }}>
                    {/* Main Orb with Waveform */}
                    <div
                        className="main-orb"
                        style={{
                            background: 'linear-gradient(135deg, #00D4AA 0%, #7D67FE 35%, #FF59D0 65%, #FAFF0E 100%)',
                            marginBottom: '32px',
                            display: 'flex', alignItems: 'center', justifyContent: 'center',
                        }}
                    >
                        {/* Orbital Rings */}
                        <div className="orb-ring" style={{
                            inset: '-20px',
                            border: '1px solid rgba(255, 255, 255, 0.2)',
                            animation: 'spin 15s linear infinite',
                        }}>
                            <div style={{
                                position: 'absolute', top: '-4px', left: '50%', transform: 'translateX(-50%)',
                                width: '8px', height: '8px', background: '#FAFF0E', borderRadius: '50%',
                            }} />
                        </div>
                        <div className="orb-ring" style={{
                            inset: '-40px',
                            border: '1px solid rgba(255, 255, 255, 0.15)',
                            animation: 'spinReverse 20s linear infinite',
                        }}>
                            <div style={{
                                position: 'absolute', bottom: '10px', right: '10px',
                                width: '6px', height: '6px', background: '#FF59D0', borderRadius: '50%',
                            }} />
                        </div>
                        <div className="orb-ring" style={{
                            inset: '-60px',
                            border: '1px solid rgba(255, 255, 255, 0.1)',
                            animation: 'spin 25s linear infinite',
                        }}>
                            <div style={{
                                position: 'absolute', top: '20px', left: '10px',
                                width: '5px', height: '5px', background: '#7D67FE', borderRadius: '50%',
                            }} />
                        </div>

                        {/* Waveform Inside Orb */}
                        <div style={{
                            position: 'relative', zIndex: 1,
                            display: 'flex', alignItems: 'center', justifyContent: 'center', gap: '4px',
                            padding: '20px',
                        }}>
                            {frequencyBars.map((h, i) => (
                                <div key={i} style={{
                                    width: '6px',
                                    height: `${h * 60}px`,
                                    background: 'rgba(255,255,255,0.9)',
                                    borderRadius: '3px',
                                    animation: `waveform ${0.6 + i * 0.1}s ease-in-out infinite`,
                                    animationDelay: `${i * 0.08}s`,
                                }} />
                            ))}
                        </div>
                    </div>

                    {/* Title */}
                    <h1 style={{
                        fontSize: '32px', fontWeight: 800,
                        margin: '0 0 8px 0', textAlign: 'center',
                        background: 'linear-gradient(135deg, #00D4AA 0%, #FAFF0E 50%, #FF59D0 100%)',
                        backgroundSize: '200% auto',
                        WebkitBackgroundClip: 'text',
                        WebkitTextFillColor: 'transparent',
                        animation: 'shimmer 3s linear infinite',
                    }}>
                        Your Sound is Ready!
                    </h1>
                    <p style={{
                        fontSize: '15px', color: 'rgba(255,255,255,0.5)',
                        margin: '0 0 32px 0', textAlign: 'center',
                        fontFamily: "'Space Grotesk', sans-serif"
                    }}>
                        A unique cosmic frequency crafted just for you
                    </p>

                    {/* Sound Stats */}
                    <div style={{
                        display: 'flex', justifyContent: 'center', gap: '12px',
                        marginBottom: '24px', width: '100%',
                        opacity: showStats ? 1 : 0,
                        transform: showStats ? 'translateY(0)' : 'translateY(20px)',
                        transition: 'all 0.6s ease',
                    }}>
                        {soundStats.map((stat, i) => (
                            <div key={i} className="stat-card" style={{
                                background: 'rgba(255, 255, 255, 0.03)',
                                border: `1px solid ${stat.color}30`,
                                borderRadius: '16px',
                                padding: '16px 12px',
                                textAlign: 'center',
                                flex: 1,
                                animationDelay: `${0.8 + i * 0.15}s`,
                            }}>
                                <div style={{ marginBottom: '8px', display: 'flex', justifyContent: 'center' }}>
                                    {stat.icon}
                                </div>
                                <p style={{
                                    fontSize: '22px', fontWeight: 800, color: stat.color, margin: '0 0 4px 0'
                                }}>
                                    {stat.value}
                                </p>
                                <p style={{
                                    fontSize: '10px', color: 'rgba(255,255,255,0.4)', margin: 0,
                                    textTransform: 'uppercase', letterSpacing: '1px'
                                }}>
                                    {stat.label}
                                </p>
                            </div>
                        ))}
                    </div>

                    {/* Celebration Card */}
                    <div style={{
                        width: '100%',
                        background: 'linear-gradient(135deg, rgba(0, 212, 170, 0.08) 0%, rgba(125, 103, 254, 0.08) 50%, rgba(255, 89, 208, 0.08) 100%)',
                        border: '1px solid rgba(255, 255, 255, 0.1)',
                        borderRadius: '20px',
                        padding: '24px',
                        textAlign: 'center',
                        opacity: showCelebration ? 1 : 0,
                        transform: showCelebration ? 'translateY(0)' : 'translateY(20px)',
                        transition: 'all 0.6s ease',
                    }}>
                        {/* Stars Row */}
                        <div style={{ display: 'flex', justifyContent: 'center', gap: '12px', marginBottom: '16px' }}>
                            <svg width="28" height="28" viewBox="0 0 28 28" fill="none" style={{ animation: 'starPulse 2s ease-in-out infinite' }}>
                                <path d="M14 2l3.5 7 7.5 1.5-5.5 5 1.5 7.5-7-4-7 4 1.5-7.5-5.5-5 7.5-1.5z" fill="#FAFF0E" />
                            </svg>
                            <svg width="32" height="32" viewBox="0 0 32 32" fill="none" style={{ animation: 'starPulse 2s ease-in-out infinite 0.3s' }}>
                                <path d="M16 2l4 8 8.5 1.5-6 5.5 1.5 8.5-8-4.5-8 4.5 1.5-8.5-6-5.5 8.5-1.5z" fill="#FF59D0" />
                            </svg>
                            <svg width="28" height="28" viewBox="0 0 28 28" fill="none" style={{ animation: 'starPulse 2s ease-in-out infinite 0.6s' }}>
                                <path d="M14 2l3.5 7 7.5 1.5-5.5 5 1.5 7.5-7-4-7 4 1.5-7.5-5.5-5 7.5-1.5z" fill="#7D67FE" />
                            </svg>
                        </div>

                        <h3 style={{ fontSize: '18px', fontWeight: 700, margin: '0 0 8px 0' }}>
                            Welcome to Astro.FM
                        </h3>
                        <p style={{
                            fontSize: '14px', color: 'rgba(255,255,255,0.5)', margin: 0,
                            fontFamily: "'Space Grotesk', sans-serif", lineHeight: 1.5
                        }}>
                            Your cosmic journey begins now.<br />
                            Tap below to hear your unique sound signature.
                        </p>
                    </div>
                </div>

                {/* CTA */}
                <div style={{
                    padding: '20px 0 40px',
                    opacity: showCelebration ? 1 : 0,
                    transition: 'opacity 0.5s ease 0.3s'
                }}>
                    <button className="cta-button" style={{
                        width: '100%',
                        background: 'linear-gradient(135deg, #FAFF0E 0%, #E5EB0D 100%)',
                        border: 'none', borderRadius: '16px', padding: '18px 32px',
                        fontSize: '16px', fontWeight: 700, fontFamily: "'Syne', sans-serif",
                        color: '#0A0A0F', cursor: 'pointer',
                        boxShadow: '0 10px 40px rgba(250, 255, 14, 0.3)',
                        display: 'flex', alignItems: 'center', justifyContent: 'center', gap: '12px',
                    }}>
                        <svg width="22" height="22" viewBox="0 0 24 24" fill="none">
                            <circle cx="12" cy="12" r="10" stroke="currentColor" strokeWidth="2" fill="none" />
                            <polygon points="10 8 16 12 10 16 10 8" fill="currentColor" />
                        </svg>
                        Play My Sound
                    </button>
                </div>
            </div>
        </div>
    );
};

export default Onboarding10_SoundReady