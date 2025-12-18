import React, { useState, useEffect } from 'react';

const Onboarding04_HowFound = () => {
    const [showContent, setShowContent] = useState(false);
    const [selected, setSelected] = useState(null);

    useEffect(() => {
        setTimeout(() => setShowContent(true), 300);
    }, []);

    const options = [
        {
            id: 'friend',
            label: 'Friend Referral',
            icon: (
                <svg width="32" height="32" viewBox="0 0 32 32" fill="none">
                    <defs>
                        <linearGradient id="friendGrad" x1="0%" y1="0%" x2="100%" y2="100%">
                            <stop offset="0%" stopColor="#FF59D0" />
                            <stop offset="100%" stopColor="#7D67FE" />
                        </linearGradient>
                    </defs>
                    <circle cx="11" cy="16" r="6" stroke="url(#friendGrad)" strokeWidth="1.5" fill="none" />
                    <circle cx="21" cy="16" r="6" stroke="url(#friendGrad)" strokeWidth="1.5" fill="none" />
                    <circle cx="16" cy="16" r="2" fill="#FAFF0E" />
                </svg>
            )
        },
        {
            id: 'tiktok',
            label: 'TikTok',
            icon: (
                <svg width="32" height="32" viewBox="0 0 32 32" fill="none">
                    <defs>
                        <linearGradient id="tiktokGrad" x1="0%" y1="0%" x2="100%" y2="100%">
                            <stop offset="0%" stopColor="#00D4AA" />
                            <stop offset="100%" stopColor="#FF59D0" />
                        </linearGradient>
                    </defs>
                    <path d="M14 6v16c0 2.2-1.8 4-4 4s-4-1.8-4-4 1.8-4 4-4" stroke="url(#tiktokGrad)" strokeWidth="1.5" fill="none" strokeLinecap="round" />
                    <path d="M14 6c0 0 0 5 6 5" stroke="url(#tiktokGrad)" strokeWidth="1.5" fill="none" strokeLinecap="round" />
                    <circle cx="10" cy="22" r="2" fill="#00D4AA" />
                </svg>
            )
        },
        {
            id: 'instagram',
            label: 'Instagram',
            icon: (
                <svg width="32" height="32" viewBox="0 0 32 32" fill="none">
                    <defs>
                        <linearGradient id="instaGrad" x1="0%" y1="100%" x2="100%" y2="0%">
                            <stop offset="0%" stopColor="#FAFF0E" />
                            <stop offset="50%" stopColor="#FF59D0" />
                            <stop offset="100%" stopColor="#7D67FE" />
                        </linearGradient>
                    </defs>
                    <rect x="6" y="6" width="20" height="20" rx="6" stroke="url(#instaGrad)" strokeWidth="1.5" fill="none" />
                    <circle cx="16" cy="16" r="5" stroke="url(#instaGrad)" strokeWidth="1.5" fill="none" />
                    <circle cx="23" cy="9" r="1.5" fill="#FF59D0" />
                </svg>
            )
        },
        {
            id: 'twitter',
            label: 'Twitter / X',
            icon: (
                <svg width="32" height="32" viewBox="0 0 32 32" fill="none">
                    <defs>
                        <linearGradient id="xGrad" x1="0%" y1="0%" x2="100%" y2="100%">
                            <stop offset="0%" stopColor="#FAFF0E" />
                            <stop offset="100%" stopColor="#FF59D0" />
                        </linearGradient>
                    </defs>
                    <path d="M8 8l16 16M24 8L8 24" stroke="url(#xGrad)" strokeWidth="2" strokeLinecap="round" />
                </svg>
            )
        },
        {
            id: 'appstore',
            label: 'App Store',
            icon: (
                <svg width="32" height="32" viewBox="0 0 32 32" fill="none">
                    <defs>
                        <linearGradient id="appGrad" x1="0%" y1="0%" x2="100%" y2="100%">
                            <stop offset="0%" stopColor="#7D67FE" />
                            <stop offset="100%" stopColor="#00D4AA" />
                        </linearGradient>
                    </defs>
                    <rect x="6" y="6" width="8" height="8" rx="2" stroke="url(#appGrad)" strokeWidth="1.5" fill="none" />
                    <rect x="18" y="6" width="8" height="8" rx="2" stroke="url(#appGrad)" strokeWidth="1.5" fill="none" />
                    <rect x="6" y="18" width="8" height="8" rx="2" stroke="url(#appGrad)" strokeWidth="1.5" fill="none" />
                    <rect x="18" y="18" width="8" height="8" rx="2" stroke="url(#appGrad)" strokeWidth="1.5" fill="url(#appGrad)" fillOpacity="0.2" />
                </svg>
            )
        },
        {
            id: 'podcast',
            label: 'Podcast',
            icon: (
                <svg width="32" height="32" viewBox="0 0 32 32" fill="none">
                    <defs>
                        <linearGradient id="podGrad" x1="0%" y1="0%" x2="100%" y2="100%">
                            <stop offset="0%" stopColor="#FF59D0" />
                            <stop offset="100%" stopColor="#FAFF0E" />
                        </linearGradient>
                    </defs>
                    <circle cx="16" cy="12" r="4" stroke="url(#podGrad)" strokeWidth="1.5" fill="none" />
                    <path d="M16 16v8M12 26h8" stroke="url(#podGrad)" strokeWidth="1.5" strokeLinecap="round" />
                    <path d="M8 14c0-4.4 3.6-8 8-8s8 3.6 8 8" stroke="url(#podGrad)" strokeWidth="1.5" fill="none" strokeLinecap="round" opacity="0.5" />
                </svg>
            )
        },
        {
            id: 'youtube',
            label: 'YouTube',
            icon: (
                <svg width="32" height="32" viewBox="0 0 32 32" fill="none">
                    <defs>
                        <linearGradient id="ytGrad" x1="0%" y1="0%" x2="100%" y2="100%">
                            <stop offset="0%" stopColor="#FF59D0" />
                            <stop offset="100%" stopColor="#7D67FE" />
                        </linearGradient>
                    </defs>
                    <rect x="4" y="8" width="24" height="16" rx="4" stroke="url(#ytGrad)" strokeWidth="1.5" fill="none" />
                    <path d="M13 12v8l7-4-7-4z" fill="url(#ytGrad)" />
                </svg>
            )
        },
        {
            id: 'other',
            label: 'Other',
            icon: (
                <svg width="32" height="32" viewBox="0 0 32 32" fill="none">
                    <defs>
                        <linearGradient id="otherGrad" x1="0%" y1="0%" x2="100%" y2="100%">
                            <stop offset="0%" stopColor="#00D4AA" />
                            <stop offset="100%" stopColor="#FAFF0E" />
                        </linearGradient>
                    </defs>
                    <circle cx="16" cy="16" r="3" fill="url(#otherGrad)" />
                    <path d="M16 4v4M16 24v4M4 16h4M24 16h4" stroke="url(#otherGrad)" strokeWidth="1.5" strokeLinecap="round" />
                    <path d="M7.5 7.5l3 3M21.5 21.5l3 3M7.5 24.5l3-3M21.5 10.5l3-3" stroke="url(#otherGrad)" strokeWidth="1.5" strokeLinecap="round" opacity="0.5" />
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
        @keyframes float { 0%, 100% { transform: translateY(0); } 50% { transform: translateY(-5px); } }
        @keyframes popIn { 0% { transform: scale(0.8); opacity: 0; } 70% { transform: scale(1.05); } 100% { transform: scale(1); opacity: 1; } }
        @keyframes checkPop { 0% { transform: scale(0); } 70% { transform: scale(1.2); } 100% { transform: scale(1); } }
        
        .option-button { transition: all 0.3s cubic-bezier(0.4, 0, 0.2, 1); }
        .option-button:hover { background: rgba(255, 255, 255, 0.08); transform: translateX(4px); }
        .option-button.selected { background: rgba(250, 255, 14, 0.1); border-color: rgba(250, 255, 14, 0.4); }
        .option-button.selected svg { animation: float 2s ease-in-out infinite; }
        .check-icon { animation: checkPop 0.4s cubic-bezier(0.4, 0, 0.2, 1); }
        .cta-button { transition: all 0.3s cubic-bezier(0.4, 0, 0.2, 1); }
        .cta-button:hover:not(:disabled) { transform: translateY(-4px); box-shadow: 0 20px 50px rgba(250, 255, 14, 0.4); }
      `}</style>

            {/* Background */}
            <div style={{
                position: 'absolute', top: '30%', left: '-20%', width: '400px', height: '400px',
                background: 'radial-gradient(circle, rgba(255, 89, 208, 0.1) 0%, transparent 60%)',
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
                    <span style={{ fontSize: '13px', color: 'rgba(255,255,255,0.4)', fontFamily: "'Space Grotesk', sans-serif" }}>Step 3 of 9</span>
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
                        background: 'linear-gradient(135deg, #7D67FE 0%, #FF59D0 100%)',
                        margin: '0 auto 32px', display: 'flex', alignItems: 'center', justifyContent: 'center',
                        boxShadow: '0 10px 40px rgba(125, 103, 254, 0.3)',
                    }}>
                        <svg width="36" height="36" viewBox="0 0 36 36" fill="none">
                            <circle cx="14" cy="14" r="8" stroke="white" strokeWidth="2" fill="none" />
                            <path d="M20 20l10 10" stroke="white" strokeWidth="2" strokeLinecap="round" />
                        </svg>
                    </div>

                    <h1 style={{ fontSize: '28px', fontWeight: 700, margin: '0 0 12px 0', textAlign: 'center' }}>How did you find us?</h1>
                    <p style={{ fontSize: '15px', color: 'rgba(255,255,255,0.5)', margin: '0 0 32px 0', textAlign: 'center', fontFamily: "'Space Grotesk', sans-serif" }}>Help us spread cosmic vibes</p>

                    {/* Options Grid */}
                    <div style={{ display: 'grid', gridTemplateColumns: 'repeat(2, 1fr)', gap: '12px' }}>
                        {options.map((option, index) => (
                            <button
                                key={option.id}
                                className={`option-button ${selected === option.id ? 'selected' : ''}`}
                                onClick={() => setSelected(option.id)}
                                style={{
                                    background: 'rgba(255, 255, 255, 0.03)',
                                    border: selected === option.id ? '1px solid rgba(250, 255, 14, 0.4)' : '1px solid rgba(255, 255, 255, 0.08)',
                                    borderRadius: '16px', padding: '20px 16px', cursor: 'pointer',
                                    display: 'flex', flexDirection: 'column', alignItems: 'center', gap: '10px',
                                    position: 'relative',
                                    animation: showContent ? `popIn 0.5s cubic-bezier(0.4, 0, 0.2, 1) ${0.1 + index * 0.05}s both` : 'none',
                                }}
                            >
                                {selected === option.id && (
                                    <div className="check-icon" style={{
                                        position: 'absolute', top: '10px', right: '10px',
                                        width: '20px', height: '20px', borderRadius: '50%', background: '#FAFF0E',
                                        display: 'flex', alignItems: 'center', justifyContent: 'center',
                                    }}>
                                        <svg width="12" height="12" viewBox="0 0 24 24" fill="none" stroke="#0A0A0F" strokeWidth="3"><polyline points="20 6 9 17 4 12" /></svg>
                                    </div>
                                )}
                                {option.icon}
                                <span style={{ fontSize: '14px', fontWeight: 600, color: selected === option.id ? '#FAFF0E' : 'white' }}>{option.label}</span>
                            </button>
                        ))}
                    </div>
                </div>

                {/* CTA */}
                <div style={{ padding: '20px 0 40px', opacity: showContent ? 1 : 0, transition: 'opacity 0.5s ease 0.3s' }}>
                    <button className="cta-button" disabled={!selected} style={{
                        width: '100%',
                        background: selected ? 'linear-gradient(135deg, #FAFF0E 0%, #E5EB0D 100%)' : 'rgba(255, 255, 255, 0.1)',
                        border: 'none', borderRadius: '16px', padding: '18px 32px',
                        fontSize: '16px', fontWeight: 700, fontFamily: "'Syne', sans-serif",
                        color: selected ? '#0A0A0F' : 'rgba(255,255,255,0.3)',
                        cursor: selected ? 'pointer' : 'not-allowed',
                        boxShadow: selected ? '0 10px 40px rgba(250, 255, 14, 0.3)' : 'none',
                        display: 'flex', alignItems: 'center', justifyContent: 'center', gap: '10px',
                    }}>
                        Continue
                        <svg width="18" height="18" viewBox="0 0 24 24" fill="none" stroke="currentColor" strokeWidth="2.5" strokeLinecap="round"><path d="M5 12h14M12 5l7 7-7 7" /></svg>
                    </button>
                </div>
            </div>
        </div>
    );
};

export default Onboarding04_HowFound;