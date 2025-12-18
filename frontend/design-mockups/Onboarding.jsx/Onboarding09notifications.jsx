import React, { useState, useEffect } from 'react';

const Onboarding09_Notifications = () => {
    const [showContent, setShowContent] = useState(false);
    const [notifications, setNotifications] = useState({
        daily: true,
        moon: true,
        transit: false,
        friend: true,
    });

    useEffect(() => {
        setTimeout(() => setShowContent(true), 300);
    }, []);

    const toggleNotification = (key) => {
        setNotifications(prev => ({ ...prev, [key]: !prev[key] }));
    };

    const notificationTypes = [
        {
            id: 'daily',
            title: 'Daily Alignment',
            description: 'Start each day tuned to the cosmos',
            time: '9:00 AM',
            icon: (
                <svg width="28" height="28" viewBox="0 0 28 28" fill="none">
                    <defs>
                        <linearGradient id="dailyGrad" x1="0%" y1="0%" x2="100%" y2="100%">
                            <stop offset="0%" stopColor="#FAFF0E" />
                            <stop offset="100%" stopColor="#FF59D0" />
                        </linearGradient>
                    </defs>
                    <circle cx="14" cy="14" r="6" stroke="url(#dailyGrad)" strokeWidth="1.5" fill="none" />
                    <path d="M14 4v2M14 22v2M4 14h2M22 14h2M6.93 6.93l1.41 1.41M19.66 19.66l1.41 1.41M6.93 21.07l1.41-1.41M19.66 8.34l1.41-1.41" stroke="url(#dailyGrad)" strokeWidth="1.5" strokeLinecap="round" />
                </svg>
            ),
            color: '#FAFF0E',
        },
        {
            id: 'moon',
            title: 'Moon Phases',
            description: 'New & full moon energy alerts',
            time: 'As they occur',
            icon: (
                <svg width="28" height="28" viewBox="0 0 28 28" fill="none">
                    <defs>
                        <linearGradient id="moonGrad" x1="0%" y1="0%" x2="100%" y2="100%">
                            <stop offset="0%" stopColor="#7D67FE" />
                            <stop offset="100%" stopColor="#FF59D0" />
                        </linearGradient>
                    </defs>
                    <circle cx="14" cy="14" r="9" stroke="url(#moonGrad)" strokeWidth="1.5" fill="none" />
                    <path d="M14 5c-3 0-6 2-7 5s0 7 3 9 7 1 9-2c-2 1-5 0-6-2s-1-5 1-7c-1 0-1 0 0-3z" fill="url(#moonGrad)" opacity="0.3" />
                </svg>
            ),
            color: '#7D67FE',
        },
        {
            id: 'transit',
            title: 'Major Transits',
            description: 'Important planetary movements',
            time: 'Weekly digest',
            icon: (
                <svg width="28" height="28" viewBox="0 0 28 28" fill="none">
                    <defs>
                        <linearGradient id="transitGrad" x1="0%" y1="0%" x2="100%" y2="100%">
                            <stop offset="0%" stopColor="#FF59D0" />
                            <stop offset="100%" stopColor="#00D4AA" />
                        </linearGradient>
                    </defs>
                    <circle cx="14" cy="14" r="10" stroke="url(#transitGrad)" strokeWidth="1.5" fill="none" />
                    <ellipse cx="14" cy="14" rx="10" ry="4" stroke="url(#transitGrad)" strokeWidth="1" fill="none" transform="rotate(30 14 14)" />
                    <circle cx="14" cy="14" r="3" fill="url(#transitGrad)" />
                    <circle cx="21" cy="10" r="2" fill="#FF59D0" />
                </svg>
            ),
            color: '#FF59D0',
        },
        {
            id: 'friend',
            title: 'Friend Alignments',
            description: 'When friends sync with you',
            time: 'Real-time',
            icon: (
                <svg width="28" height="28" viewBox="0 0 28 28" fill="none">
                    <defs>
                        <linearGradient id="friendGrad2" x1="0%" y1="0%" x2="100%" y2="100%">
                            <stop offset="0%" stopColor="#00D4AA" />
                            <stop offset="100%" stopColor="#7D67FE" />
                        </linearGradient>
                    </defs>
                    <circle cx="10" cy="10" r="4" stroke="url(#friendGrad2)" strokeWidth="1.5" fill="none" />
                    <circle cx="18" cy="10" r="4" stroke="url(#friendGrad2)" strokeWidth="1.5" fill="none" />
                    <path d="M4 22c0-3 3-5 6-5M18 22c0-3 3-5 6-5" stroke="url(#friendGrad2)" strokeWidth="1.5" fill="none" strokeLinecap="round" />
                    <path d="M14 14v4M12 16h4" stroke="url(#friendGrad2)" strokeWidth="1.5" strokeLinecap="round" />
                </svg>
            ),
            color: '#00D4AA',
        },
    ];

    const enabledCount = Object.values(notifications).filter(Boolean).length;

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
        @keyframes float { 0%, 100% { transform: translateY(0); } 50% { transform: translateY(-8px); } }
        @keyframes ring { 0%, 100% { transform: rotate(0deg); } 25% { transform: rotate(15deg); } 75% { transform: rotate(-15deg); } }
        
        .notification-card { transition: all 0.3s cubic-bezier(0.4, 0, 0.2, 1); }
        .notification-card:hover { background: rgba(255, 255, 255, 0.06); }
        
        .toggle-switch {
          position: relative; width: 52px; height: 30px;
          background: rgba(255, 255, 255, 0.1); border-radius: 15px;
          cursor: pointer; transition: all 0.3s ease;
        }
        .toggle-switch.active { background: linear-gradient(135deg, #7D67FE 0%, #FF59D0 100%); }
        .toggle-switch::after {
          content: ''; position: absolute; top: 3px; left: 3px;
          width: 24px; height: 24px; background: white; border-radius: 50%;
          transition: all 0.3s ease; box-shadow: 0 2px 8px rgba(0,0,0,0.3);
        }
        .toggle-switch.active::after { transform: translateX(22px); }
        
        .cta-button { transition: all 0.3s cubic-bezier(0.4, 0, 0.2, 1); }
        .cta-button:hover { transform: translateY(-4px); box-shadow: 0 20px 50px rgba(250, 255, 14, 0.4); }
      `}</style>

            {/* Background */}
            <div style={{
                position: 'absolute', top: '30%', left: '50%', transform: 'translateX(-50%)',
                width: '400px', height: '400px',
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
                    <span style={{ fontSize: '13px', color: 'rgba(255,255,255,0.4)', fontFamily: "'Space Grotesk', sans-serif" }}>Step 8 of 9</span>
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
                        background: 'linear-gradient(135deg, #FF59D0 0%, #FAFF0E 100%)',
                        margin: '0 auto 32px', display: 'flex', alignItems: 'center', justifyContent: 'center',
                        boxShadow: '0 10px 40px rgba(255, 89, 208, 0.3)',
                        animation: 'float 4s ease-in-out infinite',
                    }}>
                        <svg width="36" height="36" viewBox="0 0 36 36" fill="none" style={{ animation: 'ring 1s ease-in-out infinite' }}>
                            <path d="M27 12c0-5-4-9-9-9s-9 4-9 9c0 10-4.5 12-4.5 12h27s-4.5-2-4.5-12z" stroke="white" strokeWidth="2" fill="none" strokeLinecap="round" strokeLinejoin="round" />
                            <path d="M20.6 28a2 2 0 01-3.5 1.7A2 2 0 0115.4 28" stroke="white" strokeWidth="2" strokeLinecap="round" />
                            <circle cx="27" cy="9" r="4" fill="#FAFF0E" />
                        </svg>
                    </div>

                    <h1 style={{ fontSize: '28px', fontWeight: 700, margin: '0 0 12px 0', textAlign: 'center' }}>Stay cosmically tuned</h1>
                    <p style={{ fontSize: '15px', color: 'rgba(255,255,255,0.5)', margin: '0 0 32px 0', textAlign: 'center', fontFamily: "'Space Grotesk', sans-serif" }}>
                        Choose how we keep you aligned
                    </p>

                    {/* Notification Options */}
                    <div style={{ display: 'flex', flexDirection: 'column', gap: '12px' }}>
                        {notificationTypes.map((type) => (
                            <div key={type.id} className="notification-card" style={{
                                background: 'rgba(255, 255, 255, 0.03)',
                                border: notifications[type.id] ? `1px solid ${type.color}30` : '1px solid rgba(255, 255, 255, 0.08)',
                                borderRadius: '20px', padding: '18px',
                                display: 'flex', alignItems: 'center', gap: '16px',
                            }}>
                                <div style={{
                                    width: '52px', height: '52px', borderRadius: '14px',
                                    background: `${type.color}15`,
                                    display: 'flex', alignItems: 'center', justifyContent: 'center',
                                    flexShrink: 0,
                                }}>
                                    {type.icon}
                                </div>

                                <div style={{ flex: 1 }}>
                                    <h3 style={{ fontSize: '15px', fontWeight: 600, margin: '0 0 4px 0' }}>{type.title}</h3>
                                    <p style={{ fontSize: '12px', color: 'rgba(255,255,255,0.5)', margin: '0 0 4px 0', fontFamily: "'Space Grotesk', sans-serif" }}>
                                        {type.description}
                                    </p>
                                    <span style={{ fontSize: '11px', color: type.color }}>{type.time}</span>
                                </div>

                                <div
                                    className={`toggle-switch ${notifications[type.id] ? 'active' : ''}`}
                                    onClick={() => toggleNotification(type.id)}
                                />
                            </div>
                        ))}
                    </div>

                    {/* Enable All / Disable All */}
                    <div style={{ display: 'flex', justifyContent: 'center', gap: '16px', marginTop: '24px' }}>
                        <button onClick={() => setNotifications({ daily: true, moon: true, transit: true, friend: true })} style={{
                            background: 'rgba(255, 255, 255, 0.05)', border: '1px solid rgba(255, 255, 255, 0.1)',
                            borderRadius: '12px', padding: '10px 20px', cursor: 'pointer',
                            fontSize: '13px', color: 'rgba(255,255,255,0.6)', fontFamily: "'Syne', sans-serif",
                        }}>
                            Enable All
                        </button>
                        <button onClick={() => setNotifications({ daily: false, moon: false, transit: false, friend: false })} style={{
                            background: 'rgba(255, 255, 255, 0.05)', border: '1px solid rgba(255, 255, 255, 0.1)',
                            borderRadius: '12px', padding: '10px 20px', cursor: 'pointer',
                            fontSize: '13px', color: 'rgba(255,255,255,0.6)', fontFamily: "'Syne', sans-serif",
                        }}>
                            Disable All
                        </button>
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
                        {enabledCount > 0 ? `Continue with ${enabledCount} notifications` : 'Continue without notifications'}
                        <svg width="18" height="18" viewBox="0 0 24 24" fill="none" stroke="currentColor" strokeWidth="2.5" strokeLinecap="round"><path d="M5 12h14M12 5l7 7-7 7" /></svg>
                    </button>
                </div>
            </div>
        </div>
    );
};

export default Onboarding09_Notifications;