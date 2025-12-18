import React, { useState, useEffect } from 'react';

const Onboarding05_Genres = () => {
    const [showContent, setShowContent] = useState(false);
    const [selected, setSelected] = useState([]);

    useEffect(() => {
        setTimeout(() => setShowContent(true), 300);
    }, []);

    const toggleGenre = (id) => {
        setSelected(prev =>
            prev.includes(id) ? prev.filter(g => g !== id) : [...prev, id]
        );
    };

    // Custom SVG icon generator based on genre type
    const getGenreIcon = (id, isSelected) => {
        const color1 = isSelected ? '#FAFF0E' : '#FF59D0';
        const color2 = isSelected ? '#FF59D0' : '#7D67FE';

        const icons = {
            electronic: (
                <svg width="24" height="24" viewBox="0 0 24 24" fill="none">
                    <path d="M4 12L7 8L10 16L13 6L16 18L19 10L22 12" stroke={color1} strokeWidth="1.5" strokeLinecap="round" strokeLinejoin="round" />
                </svg>
            ),
            ambient: (
                <svg width="24" height="24" viewBox="0 0 24 24" fill="none">
                    <path d="M2 12c0 0 3-5 6-5s4 10 8 10 6-5 6-5" stroke={color1} strokeWidth="1.5" strokeLinecap="round" />
                    <circle cx="8" cy="10" r="1" fill={color2} opacity="0.6" />
                    <circle cx="18" cy="14" r="1" fill={color2} opacity="0.6" />
                </svg>
            ),
            house: (
                <svg width="24" height="24" viewBox="0 0 24 24" fill="none">
                    <rect x="4" y="14" width="4" height="6" rx="1" fill={color1} opacity="0.7" />
                    <rect x="10" y="10" width="4" height="10" rx="1" fill={color1} />
                    <rect x="16" y="12" width="4" height="8" rx="1" fill={color1} opacity="0.8" />
                </svg>
            ),
            techno: (
                <svg width="24" height="24" viewBox="0 0 24 24" fill="none">
                    <circle cx="12" cy="12" r="8" stroke={color1} strokeWidth="1.5" fill="none" />
                    <circle cx="12" cy="12" r="4" stroke={color2} strokeWidth="1.5" fill="none" />
                    <circle cx="12" cy="12" r="1.5" fill={color1} />
                </svg>
            ),
            lofi: (
                <svg width="24" height="24" viewBox="0 0 24 24" fill="none">
                    <path d="M6 16c0-3 2-6 6-6s6 3 6 6" stroke={color1} strokeWidth="1.5" fill="none" strokeLinecap="round" />
                    <path d="M4 18h16" stroke={color1} strokeWidth="1.5" strokeLinecap="round" />
                    <circle cx="12" cy="8" r="2" fill={color2} />
                </svg>
            ),
            indie: (
                <svg width="24" height="24" viewBox="0 0 24 24" fill="none">
                    <path d="M12 4L4 12l8 8 8-8-8-8z" stroke={color1} strokeWidth="1.5" fill="none" />
                    <circle cx="12" cy="12" r="2" fill={color2} />
                </svg>
            ),
            pop: (
                <svg width="24" height="24" viewBox="0 0 24 24" fill="none">
                    <circle cx="12" cy="12" r="7" stroke={color1} strokeWidth="1.5" fill="none" />
                    <path d="M12 5v2M12 17v2M5 12h2M17 12h2" stroke={color2} strokeWidth="1.5" strokeLinecap="round" />
                </svg>
            ),
            hiphop: (
                <svg width="24" height="24" viewBox="0 0 24 24" fill="none">
                    <rect x="5" y="14" width="3" height="6" rx="1" fill={color1} opacity="0.6" />
                    <rect x="9" y="10" width="3" height="10" rx="1" fill={color1} opacity="0.8" />
                    <rect x="13" y="6" width="3" height="14" rx="1" fill={color1} />
                    <rect x="17" y="11" width="3" height="9" rx="1" fill={color1} opacity="0.7" />
                </svg>
            ),
            rnb: (
                <svg width="24" height="24" viewBox="0 0 24 24" fill="none">
                    <path d="M4 12c2-4 4-6 8-6s6 2 8 6c-2 4-4 6-8 6s-6-2-8-6z" stroke={color1} strokeWidth="1.5" fill="none" />
                    <circle cx="12" cy="12" r="2" fill={color2} />
                </svg>
            ),
            jazz: (
                <svg width="24" height="24" viewBox="0 0 24 24" fill="none">
                    <path d="M6 16c3 0 3-8 6-8s3 12 6 8" stroke={color1} strokeWidth="1.5" fill="none" strokeLinecap="round" />
                    <circle cx="18" cy="10" r="2" fill={color2} />
                </svg>
            ),
            classical: (
                <svg width="24" height="24" viewBox="0 0 24 24" fill="none">
                    <path d="M8 4v12c0 2-1 4-3 4" stroke={color1} strokeWidth="1.5" fill="none" strokeLinecap="round" />
                    <circle cx="5" cy="20" r="2" stroke={color1} strokeWidth="1.5" fill="none" />
                    <path d="M8 8c4 0 6-2 6-4" stroke={color2} strokeWidth="1.5" fill="none" strokeLinecap="round" />
                </svg>
            ),
            soul: (
                <svg width="24" height="24" viewBox="0 0 24 24" fill="none">
                    <path d="M12 21c-4-3-8-6-8-10 0-3 2-5 5-5 2 0 3 1 3 1s1-1 3-1c3 0 5 2 5 5 0 4-4 7-8 10z" stroke={color1} strokeWidth="1.5" fill="none" />
                </svg>
            ),
            rock: (
                <svg width="24" height="24" viewBox="0 0 24 24" fill="none">
                    <path d="M4 12l4-8 4 16 4-12 4 8" stroke={color1} strokeWidth="1.5" strokeLinecap="round" strokeLinejoin="round" />
                </svg>
            ),
            metal: (
                <svg width="24" height="24" viewBox="0 0 24 24" fill="none">
                    <path d="M6 4l6 8-6 8M18 4l-6 8 6 8" stroke={color1} strokeWidth="1.5" strokeLinecap="round" strokeLinejoin="round" />
                </svg>
            ),
            country: (
                <svg width="24" height="24" viewBox="0 0 24 24" fill="none">
                    <circle cx="12" cy="16" r="4" stroke={color1} strokeWidth="1.5" fill="none" />
                    <path d="M12 4v8" stroke={color1} strokeWidth="1.5" strokeLinecap="round" />
                    <path d="M12 4c3 0 5 2 5 2" stroke={color2} strokeWidth="1.5" fill="none" strokeLinecap="round" />
                </svg>
            ),
            folk: (
                <svg width="24" height="24" viewBox="0 0 24 24" fill="none">
                    <ellipse cx="12" cy="17" rx="5" ry="3" stroke={color1} strokeWidth="1.5" fill="none" />
                    <path d="M17 17V7c0-2-2-3-5-3S7 5 7 7v10" stroke={color1} strokeWidth="1.5" fill="none" />
                </svg>
            ),
            world: (
                <svg width="24" height="24" viewBox="0 0 24 24" fill="none">
                    <circle cx="12" cy="12" r="8" stroke={color1} strokeWidth="1.5" fill="none" />
                    <ellipse cx="12" cy="12" rx="3" ry="8" stroke={color2} strokeWidth="1" fill="none" />
                    <path d="M4 12h16" stroke={color2} strokeWidth="1" />
                </svg>
            ),
            reggae: (
                <svg width="24" height="24" viewBox="0 0 24 24" fill="none">
                    <path d="M4 8h16M4 12h16M4 16h16" stroke={color1} strokeWidth="2" strokeLinecap="round" />
                </svg>
            ),
            latin: (
                <svg width="24" height="24" viewBox="0 0 24 24" fill="none">
                    <path d="M8 20c0-4 2-8 4-8s4 4 4 8" stroke={color1} strokeWidth="1.5" fill="none" strokeLinecap="round" />
                    <circle cx="12" cy="8" r="3" stroke={color2} strokeWidth="1.5" fill="none" />
                    <path d="M12 5v-2" stroke={color2} strokeWidth="1.5" strokeLinecap="round" />
                </svg>
            ),
            kpop: (
                <svg width="24" height="24" viewBox="0 0 24 24" fill="none">
                    <path d="M12 4l2 6h6l-5 4 2 6-5-4-5 4 2-6-5-4h6l2-6z" stroke={color1} strokeWidth="1.5" fill="none" strokeLinejoin="round" />
                </svg>
            ),
        };

        return icons[id] || icons.electronic;
    };

    const genres = [
        { id: 'electronic', label: 'Electronic' },
        { id: 'ambient', label: 'Ambient' },
        { id: 'house', label: 'House' },
        { id: 'techno', label: 'Techno' },
        { id: 'lofi', label: 'Lo-Fi' },
        { id: 'indie', label: 'Indie' },
        { id: 'pop', label: 'Pop' },
        { id: 'hiphop', label: 'Hip-Hop' },
        { id: 'rnb', label: 'R&B' },
        { id: 'jazz', label: 'Jazz' },
        { id: 'classical', label: 'Classical' },
        { id: 'soul', label: 'Soul' },
        { id: 'rock', label: 'Rock' },
        { id: 'metal', label: 'Metal' },
        { id: 'country', label: 'Country' },
        { id: 'folk', label: 'Folk' },
        { id: 'world', label: 'World' },
        { id: 'reggae', label: 'Reggae' },
        { id: 'latin', label: 'Latin' },
        { id: 'kpop', label: 'K-Pop' },
    ];

    const isComplete = selected.length >= 3;

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
        @keyframes bounce { 0%, 100% { transform: scale(1); } 50% { transform: scale(1.1); } }
        @keyframes wiggle { 0%, 100% { transform: rotate(0deg); } 25% { transform: rotate(-5deg); } 75% { transform: rotate(5deg); } }
        
        .genre-chip { transition: all 0.3s cubic-bezier(0.4, 0, 0.2, 1); }
        .genre-chip:hover { background: rgba(255, 255, 255, 0.1); transform: translateY(-2px); }
        .genre-chip.selected { background: rgba(250, 255, 14, 0.15); border-color: #FAFF0E; animation: bounce 0.4s ease; }
        .genre-chip.selected svg { animation: wiggle 0.5s ease; }
        .cta-button { transition: all 0.3s cubic-bezier(0.4, 0, 0.2, 1); }
        .cta-button:hover:not(:disabled) { transform: translateY(-4px); box-shadow: 0 20px 50px rgba(250, 255, 14, 0.4); }
      `}</style>

            {/* Background */}
            <div style={{
                position: 'absolute', top: '20%', right: '-20%', width: '400px', height: '400px',
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
                    <span style={{ fontSize: '13px', color: 'rgba(255,255,255,0.4)', fontFamily: "'Space Grotesk', sans-serif" }}>Step 4 of 9</span>
                    <div style={{ width: '40px' }} />
                </div>

                {/* Content */}
                <div style={{
                    flex: 1, display: 'flex', flexDirection: 'column', paddingTop: '10px',
                    opacity: showContent ? 1 : 0, transform: showContent ? 'translateY(0)' : 'translateY(20px)',
                    transition: 'all 0.8s cubic-bezier(0.4, 0, 0.2, 1)',
                }}>
                    {/* Icon */}
                    <div style={{
                        width: '80px', height: '80px', borderRadius: '20px',
                        background: 'linear-gradient(135deg, #FF59D0 0%, #FAFF0E 100%)',
                        margin: '0 auto 24px', display: 'flex', alignItems: 'center', justifyContent: 'center',
                        boxShadow: '0 10px 40px rgba(255, 89, 208, 0.3)',
                    }}>
                        <svg width="36" height="36" viewBox="0 0 36 36" fill="none">
                            <circle cx="18" cy="18" r="12" stroke="white" strokeWidth="2" fill="none" />
                            <circle cx="18" cy="18" r="6" stroke="white" strokeWidth="2" fill="none" />
                            <circle cx="18" cy="18" r="2" fill="white" />
                        </svg>
                    </div>

                    <h1 style={{ fontSize: '28px', fontWeight: 700, margin: '0 0 12px 0', textAlign: 'center' }}>Pick your vibes</h1>
                    <p style={{ fontSize: '15px', color: 'rgba(255,255,255,0.5)', margin: '0 0 8px 0', textAlign: 'center', fontFamily: "'Space Grotesk', sans-serif" }}>
                        Select genres that resonate with you
                    </p>

                    {/* Counter */}
                    <div style={{
                        display: 'flex', justifyContent: 'center', marginBottom: '24px',
                    }}>
                        <div style={{
                            background: isComplete ? 'rgba(0, 212, 170, 0.15)' : 'rgba(255, 255, 255, 0.05)',
                            border: `1px solid ${isComplete ? 'rgba(0, 212, 170, 0.3)' : 'rgba(255, 255, 255, 0.1)'}`,
                            borderRadius: '20px', padding: '6px 16px',
                        }}>
                            <span style={{ fontSize: '13px', color: isComplete ? '#00D4AA' : 'rgba(255,255,255,0.5)', fontWeight: 600 }}>
                                {selected.length} / 3 minimum {isComplete && '✓'}
                            </span>
                        </div>
                    </div>

                    {/* Genre Chips */}
                    <div style={{
                        display: 'flex', flexWrap: 'wrap', gap: '10px', justifyContent: 'center',
                        maxHeight: '340px', overflowY: 'auto', padding: '4px',
                    }}>
                        {genres.map((genre) => {
                            const isSelected = selected.includes(genre.id);
                            return (
                                <button
                                    key={genre.id}
                                    className={`genre-chip ${isSelected ? 'selected' : ''}`}
                                    onClick={() => toggleGenre(genre.id)}
                                    style={{
                                        background: 'rgba(255, 255, 255, 0.03)',
                                        border: isSelected ? '1px solid #FAFF0E' : '1px solid rgba(255, 255, 255, 0.1)',
                                        borderRadius: '24px', padding: '10px 16px', cursor: 'pointer',
                                        display: 'flex', alignItems: 'center', gap: '8px',
                                    }}
                                >
                                    {getGenreIcon(genre.id, isSelected)}
                                    <span style={{ fontSize: '14px', fontWeight: 600, color: isSelected ? '#FAFF0E' : 'white' }}>{genre.label}</span>
                                </button>
                            );
                        })}
                    </div>
                </div>

                {/* CTA */}
                <div style={{ padding: '20px 0 40px', opacity: showContent ? 1 : 0, transition: 'opacity 0.5s ease 0.3s' }}>
                    <button className="cta-button" disabled={!isComplete} style={{
                        width: '100%',
                        background: isComplete ? 'linear-gradient(135deg, #FAFF0E 0%, #E5EB0D 100%)' : 'rgba(255, 255, 255, 0.1)',
                        border: 'none', borderRadius: '16px', padding: '18px 32px',
                        fontSize: '16px', fontWeight: 700, fontFamily: "'Syne', sans-serif",
                        color: isComplete ? '#0A0A0F' : 'rgba(255,255,255,0.3)',
                        cursor: isComplete ? 'pointer' : 'not-allowed',
                        boxShadow: isComplete ? '0 10px 40px rgba(250, 255, 14, 0.3)' : 'none',
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

export default Onboarding05_Genres;