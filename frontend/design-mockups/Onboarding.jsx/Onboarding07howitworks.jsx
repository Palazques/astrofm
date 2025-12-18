import React, { useState, useEffect, useRef } from 'react';

const Onboarding07_HowItWorks = () => {
    const [showContent, setShowContent] = useState(false);
    const [activeCard, setActiveCard] = useState(0);
    const scrollRef = useRef(null);

    useEffect(() => {
        setTimeout(() => setShowContent(true), 300);
    }, []);

    const handleScroll = () => {
        if (scrollRef.current) {
            const scrollLeft = scrollRef.current.scrollLeft;
            const cardWidth = 280;
            const newActive = Math.round(scrollLeft / cardWidth);
            setActiveCard(newActive);
        }
    };

    const cards = [
        {
            id: 'nasa',
            title: 'Real NASA Data',
            description: 'We use precise astronomical data from NASA to calculate exact planetary positions at your birth moment.',
            gradient: ['#7D67FE', '#FF59D0'],
            icon: (
                <svg width="64" height="64" viewBox="0 0 64 64" fill="none">
                    <circle cx="32" cy="32" r="24" stroke="white" strokeWidth="2" fill="none" />
                    <ellipse cx="32" cy="32" rx="24" ry="8" stroke="white" strokeWidth="1.5" fill="none" opacity="0.5" />
                    <circle cx="32" cy="32" r="8" stroke="white" strokeWidth="2" fill="none" />
                    <circle cx="32" cy="32" r="3" fill="white" />
                    <circle cx="50" cy="24" r="4" fill="white" opacity="0.8" />
                    <circle cx="18" cy="40" r="3" fill="white" opacity="0.6" />
                </svg>
            )
        },
        {
            id: 'sound',
            title: 'Sound Translation',
            description: 'Each planet has a unique frequency. We convert your chart into a personalized sound signature.',
            gradient: ['#FF59D0', '#FAFF0E'],
            icon: (
                <svg width="64" height="64" viewBox="0 0 64 64" fill="none">
                    <path d="M12 32L18 24L24 40L30 20L36 44L42 28L48 36L54 32" stroke="white" strokeWidth="2" strokeLinecap="round" strokeLinejoin="round" />
                    <circle cx="30" cy="20" r="3" fill="white" opacity="0.8" />
                    <circle cx="36" cy="44" r="3" fill="white" opacity="0.8" />
                </svg>
            )
        },
        {
            id: 'align',
            title: 'Daily Alignment',
            description: 'Every day, the cosmos shifts. We update your sound and playlists to match current planetary transits.',
            gradient: ['#FAFF0E', '#00D4AA'],
            icon: (
                <svg width="64" height="64" viewBox="0 0 64 64" fill="none">
                    <circle cx="32" cy="32" r="20" stroke="white" strokeWidth="2" fill="none" />
                    <circle cx="32" cy="32" r="12" stroke="white" strokeWidth="1.5" fill="none" opacity="0.5" />
                    <path d="M32 12v8M32 44v8M12 32h8M44 32h8" stroke="white" strokeWidth="2" strokeLinecap="round" />
                    <circle cx="32" cy="32" r="4" fill="white" />
                </svg>
            )
        },
        {
            id: 'playlist',
            title: 'Cosmic Playlists',
            description: 'Music curated by the stars. Your playlists evolve with your astrological transits and mood.',
            gradient: ['#00D4AA', '#7D67FE'],
            icon: (
                <svg width="64" height="64" viewBox="0 0 64 64" fill="none">
                    <rect x="14" y="18" width="36" height="28" rx="4" stroke="white" strokeWidth="2" fill="none" />
                    <circle cx="26" cy="32" r="6" stroke="white" strokeWidth="2" fill="none" />
                    <circle cx="38" cy="32" r="6" stroke="white" strokeWidth="2" fill="none" />
                    <path d="M26 26v12M38 26v12" stroke="white" strokeWidth="2" strokeLinecap="round" />
                    <circle cx="26" cy="32" r="2" fill="white" />
                    <circle cx="38" cy="32" r="2" fill="white" />
                </svg>
            )
        },
    ];

    const bgColors = [
        'rgba(125, 103, 254, 0.15)',
        'rgba(255, 89, 208, 0.15)',
        'rgba(250, 255, 14, 0.1)',
        'rgba(0, 212, 170, 0.15)',
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
        
        .card-scroll { scroll-snap-type: x mandatory; -webkit-overflow-scrolling: touch; }
        .card-scroll::-webkit-scrollbar { display: none; }
        .card-item { scroll-snap-align: center; transition: transform 0.3s ease, opacity 0.3s ease; }
        .cta-button { transition: all 0.3s cubic-bezier(0.4, 0, 0.2, 1); }
        .cta-button:hover { transform: translateY(-4px); box-shadow: 0 20px 50px rgba(250, 255, 14, 0.4); }
      `}</style>

            {/* Dynamic Background */}
            <div style={{
                position: 'absolute', top: '30%', left: '50%', transform: 'translateX(-50%)',
                width: '500px', height: '500px',
                background: `radial-gradient(circle, ${bgColors[activeCard]} 0%, transparent 60%)`,
                borderRadius: '50%', filter: 'blur(80px)', animation: 'pulse 8s ease-in-out infinite',
                transition: 'background 0.5s ease',
            }} />

            {/* Main Container */}
            <div style={{
                maxWidth: '420px', margin: '0 auto', padding: '20px',
                position: 'relative', zIndex: 10, flex: 1, display: 'flex', flexDirection: 'column',
                width: '100%',
            }}>
                {/* Header */}
                <div style={{
                    display: 'flex', justifyContent: 'space-between', alignItems: 'center',
                    padding: '16px 0', opacity: showContent ? 1 : 0, transition: 'opacity 0.5s ease',
                }}>
                    <button style={{ background: 'rgba(255, 255, 255, 0.05)', border: 'none', borderRadius: '12px', padding: '10px', cursor: 'pointer' }}>
                        <svg width="20" height="20" viewBox="0 0 24 24" fill="none" stroke="white" strokeWidth="2" strokeLinecap="round"><path d="M19 12H5M12 19l-7-7 7-7" /></svg>
                    </button>
                    <span style={{ fontSize: '13px', color: 'rgba(255,255,255,0.4)', fontFamily: "'Space Grotesk', sans-serif" }}>Step 6 of 9</span>
                    <button style={{ background: 'transparent', border: 'none', padding: '10px', cursor: 'pointer', fontSize: '14px', color: 'rgba(255,255,255,0.5)' }}>Skip</button>
                </div>

                {/* Content */}
                <div style={{
                    flex: 1, display: 'flex', flexDirection: 'column', paddingTop: '20px',
                    opacity: showContent ? 1 : 0, transform: showContent ? 'translateY(0)' : 'translateY(20px)',
                    transition: 'all 0.8s cubic-bezier(0.4, 0, 0.2, 1)',
                }}>
                    <h1 style={{ fontSize: '28px', fontWeight: 700, margin: '0 0 12px 0', textAlign: 'center' }}>How it works</h1>
                    <p style={{ fontSize: '15px', color: 'rgba(255,255,255,0.5)', margin: '0 0 32px 0', textAlign: 'center', fontFamily: "'Space Grotesk', sans-serif" }}>
                        Science meets spirituality
                    </p>

                    {/* Swipeable Cards */}
                    <div
                        ref={scrollRef}
                        className="card-scroll"
                        onScroll={handleScroll}
                        style={{
                            display: 'flex', gap: '16px', overflowX: 'auto',
                            padding: '20px 0', marginLeft: '-20px', marginRight: '-20px', paddingLeft: '70px', paddingRight: '70px',
                        }}
                    >
                        {cards.map((card, index) => (
                            <div
                                key={card.id}
                                className="card-item"
                                style={{
                                    minWidth: '280px', maxWidth: '280px',
                                    background: 'rgba(255, 255, 255, 0.03)',
                                    border: '1px solid rgba(255, 255, 255, 0.08)',
                                    borderRadius: '24px', padding: '28px',
                                    transform: activeCard === index ? 'scale(1)' : 'scale(0.95)',
                                    opacity: activeCard === index ? 1 : 0.6,
                                }}
                            >
                                {/* Card Number */}
                                <div style={{
                                    position: 'absolute', top: '16px', right: '16px',
                                    background: `linear-gradient(135deg, ${card.gradient[0]}, ${card.gradient[1]})`,
                                    borderRadius: '8px', padding: '4px 10px',
                                    fontSize: '12px', fontWeight: 700,
                                }}>
                                    {index + 1}/{cards.length}
                                </div>

                                {/* Icon */}
                                <div style={{
                                    width: '100px', height: '100px', borderRadius: '24px',
                                    background: `linear-gradient(135deg, ${card.gradient[0]} 0%, ${card.gradient[1]} 100%)`,
                                    margin: '0 auto 24px', display: 'flex', alignItems: 'center', justifyContent: 'center',
                                    boxShadow: `0 10px 40px ${card.gradient[0]}40`,
                                }}>
                                    {card.icon}
                                </div>

                                <h3 style={{ fontSize: '20px', fontWeight: 700, margin: '0 0 12px 0', textAlign: 'center' }}>{card.title}</h3>
                                <p style={{ fontSize: '14px', color: 'rgba(255,255,255,0.6)', margin: 0, textAlign: 'center', lineHeight: '1.6', fontFamily: "'Space Grotesk', sans-serif" }}>
                                    {card.description}
                                </p>
                            </div>
                        ))}
                    </div>

                    {/* Dot Indicators */}
                    <div style={{ display: 'flex', justifyContent: 'center', gap: '8px', marginTop: '24px' }}>
                        {cards.map((_, index) => (
                            <div
                                key={index}
                                style={{
                                    width: activeCard === index ? '24px' : '8px',
                                    height: '8px',
                                    borderRadius: '4px',
                                    background: activeCard === index ? '#FAFF0E' : 'rgba(255, 255, 255, 0.2)',
                                    transition: 'all 0.3s ease',
                                    cursor: 'pointer',
                                }}
                                onClick={() => {
                                    if (scrollRef.current) {
                                        scrollRef.current.scrollTo({ left: index * 296, behavior: 'smooth' });
                                    }
                                }}
                            />
                        ))}
                    </div>
                </div>

                {/* CTA */}
                <div style={{ padding: '20px 0 40px', opacity: showContent ? 1 : 0, transition: 'opacity 0.5s ease 0.3s' }}>
                    <button className="cta-button" style={{
                        width: '100%',
                        background: 'linear-gradient(135deg, #FAFF0E 0%, #E5EB0D 100%)',
                        border: 'none', borderRadius: '16px', padding: '18px 32px',
                        fontSize: '16px', fontWeight: 700, fontFamily: "'Syne', sans-serif",
                        color: '#0A0A0F', cursor: 'pointer',
                        boxShadow: '0 10px 40px rgba(250, 255, 14, 0.3)',
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

export default Onboarding07_HowItWorks;