import React, { useState, useEffect } from 'react';

const Onboarding06_ConnectMusic = () => {
    const [showContent, setShowContent] = useState(false);
    const [connecting, setConnecting] = useState(null);
    const [connected, setConnected] = useState([]);

    useEffect(() => {
        setTimeout(() => setShowContent(true), 300);
    }, []);

    const handleConnect = (platform) => {
        setConnecting(platform);
        setTimeout(() => {
            setConnected([...connected, platform]);
            setConnecting(null);
        }, 2000);
    };

    const platforms = [
        {
            id: 'spotify',
            name: 'Spotify',
            description: 'Sync your playlists and listening history',
            color: '#1DB954',
            icon: (
                <svg width="32" height="32" viewBox="0 0 32 32" fill="none">
                    <circle cx="16" cy="16" r="12" stroke="#1DB954" strokeWidth="1.5" fill="none" />
                    <path d="M10 13c4-1 8-1 12 1" stroke="#1DB954" strokeWidth="1.5" strokeLinecap="round" />
                    <path d="M11 17c3-.8 6-.8 9 .5" stroke="#1DB954" strokeWidth="1.5" strokeLinecap="round" />
                    <path d="M12 21c2-.5 4-.5 6 .3" stroke="#1DB954" strokeWidth="1.5" strokeLinecap="round" />
                </svg>
            )
        },
        {
            id: 'apple',
            name: 'Apple Music',
            description: 'Connect your Apple Music library',
            color: '#FA2D48',
            icon: (
                <svg width="32" height="32" viewBox="0 0 32 32" fill="none">
                    <circle cx="10" cy="22" r="4" stroke="#FA2D48" strokeWidth="1.5" fill="none" />
                    <circle cx="22" cy="20" r="4" stroke="#FA2D48" strokeWidth="1.5" fill="none" />
                    <path d="M14 22V8l12-2v14" stroke="#FA2D48" strokeWidth="1.5" fill="none" strokeLinecap="round" strokeLinejoin="round" />
                </svg>
            )
        },
        {
            id: 'youtube',
            name: 'YouTube Music',
            description: 'Import your YouTube Music preferences',
            color: '#FF0000',
            icon: (
                <svg width="32" height="32" viewBox="0 0 32 32" fill="none">
                    <rect x="4" y="8" width="24" height="16" rx="4" stroke="#FF0000" strokeWidth="1.5" fill="none" />
                    <path d="M13 12v8l7-4-7-4z" fill="#FF0000" />
                </svg>
            )
        },
    ];

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
        
        @keyframes pulse { 0%, 100% { opacity: 0.5; } 50% { opacity: 0.8; } }
        @keyframes spin { 0% { transform: rotate(0deg); } 100% { transform: rotate(360deg); } }
        @keyframes checkPop { 0% { transform: scale(0); } 70% { transform: scale(1.2); } 100% { transform: scale(1); } }
        
        .platform-card { transition: all 0.3s cubic-bezier(0.4, 0, 0.2, 1); }
        .platform-card:hover { background: rgba(255, 255, 255, 0.06); transform: translateY(-2px); }
        .connect-button { transition: all 0.3s ease; }
        .connect-button:hover { transform: scale(1.05); }
        .cta-button { transition: all 0.3s cubic-bezier(0.4, 0, 0.2, 1); }
        .cta-button:hover:not(:disabled) { transform: translateY(-4px); box-shadow: 0 20px 50px rgba(250, 255, 14, 0.4); }
      `}</style>

            {/* Background */}
            <div style={{
                position: 'absolute', top: '30%', left: '50%', transform: 'translateX(-50%)',
                width: '400px', height: '400px',
                background: 'radial-gradient(circle, rgba(125, 103, 254, 0.1) 0%, transparent 60%)',
                borderRadius: '50%', filter: 'blur(60px)', animation: 'pulse 10s ease-in-out infinite',
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
                    <button style={{ background: 'rgba(255, 255, 255, 0.05)', border: 'none', borderRadius: '12px', padding: '10px', cursor: 'pointer' }}>
                        <svg width="20" height="20" viewBox="0 0 24 24" fill="none" stroke="white" strokeWidth="2" strokeLinecap="round"><path d="M19 12H5M12 19l-7-7 7-7" /></svg>
                    </button>
                    <span style={{ fontSize: '13px', color: 'rgba(255,255,255,0.4)', fontFamily: "'Space Grotesk', sans-serif" }}>Step 5 of 9</span>
                    <button style={{ background: 'transparent', border: 'none', padding: '10px', cursor: 'pointer', fontSize: '14px', color: 'rgba(255,255,255,0.5)' }}>Skip</button>
                </div>

                {/* Content */}
                <div style={{
                    flex: 1, display: 'flex', flexDirection: 'column', paddingTop: '20px',
                    opacity: showContent ? 1 : 0, transform: showContent ? 'translateY(0)' : 'translateY(20px)',
                    transition: 'all 0.8s cubic-bezier(0.4, 0, 0.2, 1)',
                }}>
                    {/* Icon */}
                    <div style={{
                        width: '80px', height: '80px', borderRadius: '20px',
                        background: 'linear-gradient(135deg, #7D67FE 0%, #00D4AA 100%)',
                        margin: '0 auto 32px', display: 'flex', alignItems: 'center', justifyContent: 'center',
                        boxShadow: '0 10px 40px rgba(125, 103, 254, 0.3)',
                    }}>
                        <svg width="36" height="36" viewBox="0 0 36 36" fill="none">
                            <path d="M8 12h6v12H8zM22 12h6v12h-6z" stroke="white" strokeWidth="2" fill="none" strokeLinecap="round" />
                            <path d="M14 18h8" stroke="white" strokeWidth="2" strokeLinecap="round" />
                            <circle cx="14" cy="18" r="2" fill="white" />
                            <circle cx="22" cy="18" r="2" fill="white" />
                        </svg>
                    </div>

                    <h1 style={{ fontSize: '28px', fontWeight: 700, margin: '0 0 12px 0', textAlign: 'center' }}>Connect your music</h1>
                    <p style={{ fontSize: '15px', color: 'rgba(255,255,255,0.5)', margin: '0 0 32px 0', textAlign: 'center', fontFamily: "'Space Grotesk', sans-serif" }}>
                        Sync your listening for personalized cosmic playlists
                    </p>

                    {/* Platform Cards */}
                    <div style={{ display: 'flex', flexDirection: 'column', gap: '12px' }}>
                        {platforms.map((platform) => {
                            const isConnected = connected.includes(platform.id);
                            const isConnecting = connecting === platform.id;

                            return (
                                <div key={platform.id} className="platform-card" style={{
                                    background: 'rgba(255, 255, 255, 0.03)',
                                    border: isConnected ? `1px solid ${platform.color}40` : '1px solid rgba(255, 255, 255, 0.08)',
                                    borderRadius: '20px', padding: '20px',
                                    display: 'flex', alignItems: 'center', gap: '16px',
                                }}>
                                    <div style={{
                                        width: '56px', height: '56px', borderRadius: '14px',
                                        background: `${platform.color}15`,
                                        display: 'flex', alignItems: 'center', justifyContent: 'center',
                                    }}>
                                        {platform.icon}
                                    </div>

                                    <div style={{ flex: 1 }}>
                                        <h3 style={{ fontSize: '16px', fontWeight: 600, margin: '0 0 4px 0' }}>{platform.name}</h3>
                                        <p style={{ fontSize: '13px', color: 'rgba(255,255,255,0.5)', margin: 0, fontFamily: "'Space Grotesk', sans-serif" }}>
                                            {platform.description}
                                        </p>
                                    </div>

                                    {isConnected ? (
                                        <div style={{
                                            width: '40px', height: '40px', borderRadius: '50%',
                                            background: '#00D4AA', display: 'flex', alignItems: 'center', justifyContent: 'center',
                                            animation: 'checkPop 0.4s ease',
                                        }}>
                                            <svg width="20" height="20" viewBox="0 0 24 24" fill="none" stroke="white" strokeWidth="3">
                                                <polyline points="20 6 9 17 4 12" />
                                            </svg>
                                        </div>
                                    ) : isConnecting ? (
                                        <div style={{
                                            width: '40px', height: '40px', borderRadius: '50%',
                                            border: `2px solid ${platform.color}`,
                                            borderTopColor: 'transparent',
                                            animation: 'spin 1s linear infinite',
                                        }} />
                                    ) : (
                                        <button className="connect-button" onClick={() => handleConnect(platform.id)} style={{
                                            background: `${platform.color}20`,
                                            border: `1px solid ${platform.color}40`,
                                            borderRadius: '12px', padding: '10px 16px',
                                            fontSize: '13px', fontWeight: 600, color: platform.color,
                                            cursor: 'pointer', fontFamily: "'Syne', sans-serif",
                                        }}>
                                            Connect
                                        </button>
                                    )}
                                </div>
                            );
                        })}
                    </div>

                    {/* Privacy Note */}
                    <div style={{
                        marginTop: '24px', padding: '16px',
                        background: 'rgba(255, 255, 255, 0.02)',
                        borderRadius: '12px', display: 'flex', gap: '12px', alignItems: 'flex-start',
                    }}>
                        <svg width="20" height="20" viewBox="0 0 24 24" fill="none" stroke="rgba(255,255,255,0.4)" strokeWidth="1.5" style={{ flexShrink: 0, marginTop: '2px' }}>
                            <rect x="3" y="11" width="18" height="11" rx="2" fill="none" />
                            <path d="M7 11V7a5 5 0 0110 0v4" />
                            <circle cx="12" cy="16" r="1" fill="rgba(255,255,255,0.4)" />
                        </svg>
                        <p style={{ fontSize: '12px', color: 'rgba(255,255,255,0.4)', margin: 0, lineHeight: '1.5', fontFamily: "'Space Grotesk', sans-serif" }}>
                            We only read your listening data to personalize your experience. We never post or share without permission.
                        </p>
                    </div>
                </div>

                {/* CTA */}
                <div style={{ padding: '20px 0 40px', opacity: showContent ? 1 : 0, transition: 'opacity 0.5s ease 0.3s' }}>
                    <button className="cta-button" style={{
                        width: '100%',
                        background: connected.length > 0 ? 'linear-gradient(135deg, #FAFF0E 0%, #E5EB0D 100%)' : 'rgba(255, 255, 255, 0.1)',
                        border: 'none', borderRadius: '16px', padding: '18px 32px',
                        fontSize: '16px', fontWeight: 700, fontFamily: "'Syne', sans-serif",
                        color: connected.length > 0 ? '#0A0A0F' : 'rgba(255,255,255,0.5)',
                        cursor: 'pointer',
                        boxShadow: connected.length > 0 ? '0 10px 40px rgba(250, 255, 14, 0.3)' : 'none',
                        display: 'flex', alignItems: 'center', justifyContent: 'center', gap: '10px',
                    }}>
                        {connected.length > 0 ? 'Continue' : 'Skip for now'}
                        <svg width="18" height="18" viewBox="0 0 24 24" fill="none" stroke="currentColor" strokeWidth="2.5" strokeLinecap="round"><path d="M5 12h14M12 5l7 7-7 7" /></svg>
                    </button>
                </div>
            </div>
        </div>
    );
};

export default Onboarding06_ConnectMusic;