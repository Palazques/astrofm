import React, { useState, useEffect } from 'react';

const Onboarding08_Referral = () => {
    const [showContent, setShowContent] = useState(false);
    const [showShareModal, setShowShareModal] = useState(false);
    const [copied, setCopied] = useState(false);
    const [invitedFriends, setInvitedFriends] = useState(0);

    useEffect(() => {
        setTimeout(() => setShowContent(true), 300);
    }, []);

    const handleCopy = () => {
        setCopied(true);
        setTimeout(() => setCopied(false), 2000);
    };

    const shareOptions = [
        {
            id: 'messages',
            label: 'Messages',
            icon: (
                <svg width="28" height="28" viewBox="0 0 28 28" fill="none">
                    <rect x="4" y="6" width="20" height="14" rx="4" stroke="#00D4AA" strokeWidth="1.5" fill="none" />
                    <path d="M4 10l10 6 10-6" stroke="#00D4AA" strokeWidth="1.5" fill="none" />
                </svg>
            ),
            color: '#00D4AA'
        },
        {
            id: 'whatsapp',
            label: 'WhatsApp',
            icon: (
                <svg width="28" height="28" viewBox="0 0 28 28" fill="none">
                    <circle cx="14" cy="14" r="10" stroke="#25D366" strokeWidth="1.5" fill="none" />
                    <path d="M10 17l-1 3 3-1c1 .5 2.5.5 3.5 0 2.5-1.5 3-5 .5-7s-5-1.5-6.5 1c-.5 1-.5 2.5 0 3.5" stroke="#25D366" strokeWidth="1.5" fill="none" strokeLinecap="round" />
                </svg>
            ),
            color: '#25D366'
        },
        {
            id: 'twitter',
            label: 'Twitter',
            icon: (
                <svg width="28" height="28" viewBox="0 0 28 28" fill="none">
                    <path d="M8 8l12 12M20 8L8 20" stroke="#1DA1F2" strokeWidth="2" strokeLinecap="round" />
                </svg>
            ),
            color: '#1DA1F2'
        },
        {
            id: 'copy',
            label: 'Copy Link',
            icon: (
                <svg width="28" height="28" viewBox="0 0 28 28" fill="none">
                    <rect x="10" y="6" width="12" height="16" rx="2" stroke="#FF59D0" strokeWidth="1.5" fill="none" />
                    <path d="M6 10v10a2 2 0 002 2h8" stroke="#FF59D0" strokeWidth="1.5" fill="none" strokeLinecap="round" />
                </svg>
            ),
            color: '#FF59D0'
        },
    ];

    const premiumFeatures = [
        {
            icon: (
                <svg width="24" height="24" viewBox="0 0 24 24" fill="none">
                    <path d="M12 2L2 7l10 5 10-5-10-5zM2 17l10 5 10-5M2 12l10 5 10-5" stroke="#7D67FE" strokeWidth="1.5" strokeLinecap="round" strokeLinejoin="round" />
                </svg>
            ),
            label: 'Unlimited Alignments'
        },
        {
            icon: (
                <svg width="24" height="24" viewBox="0 0 24 24" fill="none">
                    <path d="M12 2v4M12 18v4M4.93 4.93l2.83 2.83M16.24 16.24l2.83 2.83M2 12h4M18 12h4M4.93 19.07l2.83-2.83M16.24 7.76l2.83-2.83" stroke="#FAFF0E" strokeWidth="1.5" strokeLinecap="round" />
                    <circle cx="12" cy="12" r="4" stroke="#FAFF0E" strokeWidth="1.5" fill="none" />
                </svg>
            ),
            label: 'Advanced Transits'
        },
        {
            icon: (
                <svg width="24" height="24" viewBox="0 0 24 24" fill="none">
                    <circle cx="12" cy="12" r="8" stroke="#FF59D0" strokeWidth="1.5" fill="none" />
                    <path d="M12 4v4M12 16v4M4 12h4M16 12h4" stroke="#FF59D0" strokeWidth="1.5" strokeLinecap="round" />
                </svg>
            ),
            label: 'Custom Frequencies'
        },
        {
            icon: (
                <svg width="24" height="24" viewBox="0 0 24 24" fill="none">
                    <rect x="4" y="4" width="16" height="16" rx="4" stroke="#00D4AA" strokeWidth="1.5" fill="none" />
                    <path d="M9 12l2 2 4-4" stroke="#00D4AA" strokeWidth="1.5" strokeLinecap="round" strokeLinejoin="round" />
                </svg>
            ),
            label: 'Priority Support'
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
        @keyframes float { 0%, 100% { transform: translateY(0); } 50% { transform: translateY(-10px); } }
        @keyframes wiggle { 0%, 100% { transform: rotate(0deg); } 25% { transform: rotate(-5deg); } 75% { transform: rotate(5deg); } }
        @keyframes shine { 0% { left: -100%; } 100% { left: 200%; } }
        @keyframes slideUp { from { transform: translateY(100%); } to { transform: translateY(0); } }
        @keyframes fadeIn { from { opacity: 0; } to { opacity: 1; } }
        
        .share-button { transition: all 0.3s ease; }
        .share-button:hover { transform: scale(1.05); background: rgba(255, 255, 255, 0.1); }
        .cta-button { transition: all 0.3s cubic-bezier(0.4, 0, 0.2, 1); }
        .cta-button:hover { transform: translateY(-4px); box-shadow: 0 20px 50px rgba(125, 103, 254, 0.4); }
        .modal-overlay { animation: fadeIn 0.3s ease; }
        .modal-content { animation: slideUp 0.4s cubic-bezier(0.4, 0, 0.2, 1); }
      `}</style>

            {/* Background */}
            <div style={{
                position: 'absolute', top: '20%', left: '50%', transform: 'translateX(-50%)',
                width: '400px', height: '400px',
                background: 'radial-gradient(circle, rgba(125, 103, 254, 0.15) 0%, transparent 60%)',
                borderRadius: '50%', filter: 'blur(60px)', animation: 'pulse 10s ease-in-out infinite',
            }} />

            {/* Share Modal */}
            {showShareModal && (
                <div className="modal-overlay" onClick={() => setShowShareModal(false)} style={{
                    position: 'fixed', inset: 0, background: 'rgba(0,0,0,0.8)', zIndex: 100,
                    display: 'flex', alignItems: 'flex-end', justifyContent: 'center',
                }}>
                    <div className="modal-content" onClick={(e) => e.stopPropagation()} style={{
                        width: '100%', maxWidth: '420px', background: '#1a1a24',
                        borderRadius: '24px 24px 0 0', padding: '24px', paddingBottom: '40px',
                    }}>
                        <div style={{ width: '40px', height: '4px', background: 'rgba(255,255,255,0.2)', borderRadius: '2px', margin: '0 auto 24px' }} />
                        <h3 style={{ fontSize: '20px', fontWeight: 700, marginBottom: '24px', textAlign: 'center' }}>Share with friends</h3>

                        <div style={{ display: 'grid', gridTemplateColumns: 'repeat(4, 1fr)', gap: '16px', marginBottom: '24px' }}>
                            {shareOptions.map((option) => (
                                <button key={option.id} className="share-button" onClick={() => option.id === 'copy' && handleCopy()} style={{
                                    background: 'rgba(255, 255, 255, 0.05)',
                                    border: '1px solid rgba(255, 255, 255, 0.1)',
                                    borderRadius: '16px', padding: '16px', cursor: 'pointer',
                                    display: 'flex', flexDirection: 'column', alignItems: 'center', gap: '8px',
                                }}>
                                    {option.icon}
                                    <span style={{ fontSize: '11px', color: 'rgba(255,255,255,0.6)' }}>{option.label}</span>
                                </button>
                            ))}
                        </div>

                        <div style={{
                            background: 'rgba(255, 255, 255, 0.05)', borderRadius: '12px',
                            padding: '12px 16px', display: 'flex', alignItems: 'center', gap: '12px',
                        }}>
                            <input value="astro.fm/invite/cosmicpaul" readOnly style={{
                                flex: 1, background: 'transparent', border: 'none', outline: 'none',
                                fontSize: '14px', color: 'rgba(255,255,255,0.6)', fontFamily: "'Space Grotesk', sans-serif",
                            }} />
                            <button onClick={handleCopy} style={{
                                background: copied ? '#00D4AA' : '#FAFF0E',
                                border: 'none', borderRadius: '8px', padding: '8px 16px',
                                fontSize: '13px', fontWeight: 600, color: '#0A0A0F', cursor: 'pointer',
                                transition: 'all 0.3s ease',
                            }}>
                                {copied ? 'Copied!' : 'Copy'}
                            </button>
                        </div>
                    </div>
                </div>
            )}

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
                    <span style={{ fontSize: '13px', color: 'rgba(255,255,255,0.4)', fontFamily: "'Space Grotesk', sans-serif" }}>Step 7 of 9</span>
                    <button style={{ background: 'transparent', border: 'none', padding: '10px', cursor: 'pointer', fontSize: '14px', color: 'rgba(255,255,255,0.5)' }}>Skip</button>
                </div>

                {/* Content */}
                <div style={{
                    flex: 1, display: 'flex', flexDirection: 'column', alignItems: 'center', paddingTop: '10px',
                    opacity: showContent ? 1 : 0, transform: showContent ? 'translateY(0)' : 'translateY(20px)',
                    transition: 'all 0.8s cubic-bezier(0.4, 0, 0.2, 1)',
                }}>
                    {/* Gift Icon */}
                    <div style={{
                        width: '100px', height: '100px', borderRadius: '28px',
                        background: 'linear-gradient(135deg, #7D67FE 0%, #FF59D0 100%)',
                        display: 'flex', alignItems: 'center', justifyContent: 'center',
                        marginBottom: '24px', position: 'relative',
                        animation: 'float 4s ease-in-out infinite',
                        boxShadow: '0 15px 50px rgba(125, 103, 254, 0.4)',
                    }}>
                        <svg width="48" height="48" viewBox="0 0 48 48" fill="none" style={{ animation: 'wiggle 2s ease-in-out infinite' }}>
                            <rect x="8" y="20" width="32" height="22" rx="4" stroke="white" strokeWidth="2" fill="none" />
                            <path d="M24 20v22M8 28h32" stroke="white" strokeWidth="2" />
                            <path d="M24 20c-4-4-8-8-8-12 0-2 2-4 4-4s4 2 4 4v12z" stroke="white" strokeWidth="2" fill="none" />
                            <path d="M24 20c4-4 8-8 8-12 0-2-2-4-4-4s-4 2-4 4v12z" stroke="white" strokeWidth="2" fill="none" />
                        </svg>
                    </div>

                    {/* Offer Badge */}
                    <div style={{
                        background: 'linear-gradient(135deg, #FAFF0E 0%, #FF59D0 100%)',
                        borderRadius: '20px', padding: '8px 20px', marginBottom: '16px',
                        position: 'relative', overflow: 'hidden',
                    }}>
                        <div style={{
                            position: 'absolute', top: 0, left: '-100%', width: '50%', height: '100%',
                            background: 'linear-gradient(90deg, transparent, rgba(255,255,255,0.4), transparent)',
                            animation: 'shine 2s ease-in-out infinite',
                        }} />
                        <span style={{ fontSize: '14px', fontWeight: 800, color: '#0A0A0F' }}>LIFETIME 50% OFF</span>
                    </div>

                    <h1 style={{ fontSize: '28px', fontWeight: 700, margin: '0 0 12px 0', textAlign: 'center' }}>Invite 3 friends</h1>
                    <p style={{ fontSize: '15px', color: 'rgba(255,255,255,0.5)', margin: '0 0 24px 0', textAlign: 'center', fontFamily: "'Space Grotesk', sans-serif" }}>
                        Unlock Premium features forever
                    </p>

                    {/* Progress */}
                    <div style={{ width: '100%', marginBottom: '20px' }}>
                        <div style={{ display: 'flex', justifyContent: 'space-between', marginBottom: '8px' }}>
                            <span style={{ fontSize: '13px', color: 'rgba(255,255,255,0.5)' }}>Progress</span>
                            <span style={{ fontSize: '13px', fontWeight: 600, color: '#FAFF0E' }}>{invitedFriends}/3 friends</span>
                        </div>
                        <div style={{ height: '8px', background: 'rgba(255, 255, 255, 0.1)', borderRadius: '4px', overflow: 'hidden' }}>
                            <div style={{
                                width: `${(invitedFriends / 3) * 100}%`,
                                height: '100%', background: 'linear-gradient(90deg, #7D67FE, #FF59D0)',
                                borderRadius: '4px', transition: 'width 0.5s ease',
                            }} />
                        </div>
                    </div>

                    {/* Friend Slots */}
                    <div style={{ display: 'flex', gap: '16px', marginBottom: '24px' }}>
                        {[0, 1, 2].map((i) => (
                            <div key={i} style={{
                                width: '56px', height: '56px', borderRadius: '50%',
                                border: i < invitedFriends ? 'none' : '2px dashed rgba(255,255,255,0.2)',
                                background: i < invitedFriends ? 'linear-gradient(135deg, #7D67FE, #FF59D0)' : 'transparent',
                                display: 'flex', alignItems: 'center', justifyContent: 'center',
                            }}>
                                {i < invitedFriends ? (
                                    <svg width="24" height="24" viewBox="0 0 24 24" fill="none" stroke="white" strokeWidth="2"><polyline points="20 6 9 17 4 12" /></svg>
                                ) : (
                                    <svg width="24" height="24" viewBox="0 0 24 24" fill="none" stroke="rgba(255,255,255,0.3)" strokeWidth="1.5">
                                        <circle cx="12" cy="8" r="4" />
                                        <path d="M4 20c0-4 4-6 8-6s8 2 8 6" />
                                    </svg>
                                )}
                            </div>
                        ))}
                    </div>

                    {/* Premium Features */}
                    <div style={{
                        width: '100%', background: 'rgba(255, 255, 255, 0.03)',
                        border: '1px solid rgba(255, 255, 255, 0.08)',
                        borderRadius: '20px', padding: '20px',
                    }}>
                        <p style={{ fontSize: '12px', color: 'rgba(255,255,255,0.4)', marginBottom: '16px', textAlign: 'center', textTransform: 'uppercase', letterSpacing: '1px' }}>
                            Premium includes
                        </p>
                        <div style={{ display: 'grid', gridTemplateColumns: 'repeat(2, 1fr)', gap: '12px' }}>
                            {premiumFeatures.map((feature, i) => (
                                <div key={i} style={{ display: 'flex', alignItems: 'center', gap: '10px' }}>
                                    {feature.icon}
                                    <span style={{ fontSize: '12px', color: 'rgba(255,255,255,0.7)' }}>{feature.label}</span>
                                </div>
                            ))}
                        </div>
                    </div>
                </div>

                {/* CTA */}
                <div style={{ padding: '20px 0 40px', opacity: showContent ? 1 : 0, transition: 'opacity 0.5s ease 0.3s' }}>
                    <button className="cta-button" onClick={() => setShowShareModal(true)} style={{
                        width: '100%',
                        background: 'linear-gradient(135deg, #7D67FE 0%, #FF59D0 100%)',
                        border: 'none', borderRadius: '16px', padding: '18px 32px',
                        fontSize: '16px', fontWeight: 700, fontFamily: "'Syne', sans-serif",
                        color: '#FFFFFF', cursor: 'pointer',
                        boxShadow: '0 10px 40px rgba(125, 103, 254, 0.3)',
                        display: 'flex', alignItems: 'center', justifyContent: 'center', gap: '10px',
                    }}>
                        <svg width="20" height="20" viewBox="0 0 24 24" fill="none" stroke="currentColor" strokeWidth="2">
                            <circle cx="18" cy="5" r="3" /><circle cx="6" cy="12" r="3" /><circle cx="18" cy="19" r="3" />
                            <path d="M8.59 13.51l6.83 3.98M15.41 6.51l-6.82 3.98" />
                        </svg>
                        Invite Friends
                    </button>

                    <button style={{
                        width: '100%', marginTop: '12px',
                        background: 'transparent', border: 'none',
                        fontSize: '14px', color: 'rgba(255,255,255,0.5)', cursor: 'pointer',
                        fontFamily: "'Syne', sans-serif", padding: '12px',
                    }}>
                        Maybe later
                    </button>
                </div>
            </div>
        </div>
    );
};

export default Onboarding08_Referral;